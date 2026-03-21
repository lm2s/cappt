import BreedDetails
import ComposableArchitecture
import IssueReporting
import PersistenceKit

@Reducer
public struct BreedsList {
    @Dependency(\.breedsService) var breedsService
    @Dependency(\.breedsCacheClient) var breedsCacheClient

    static let pageSize = 30

    public enum Tab: Equatable {
        case allBreeds
        case favorites
        case search
    }

    @ObservableState
    public struct State: Equatable {
        var hasLoadedBreeds = false
        var breeds: [Breed] = []
        var isLoading = false
        var isLoadingMore = false
        var hasError = false
        var hasMorePages = true
        var currentPage = 0
        var pendingPage: Int?
        var selectedTab: Tab = .allBreeds
        var searchText = ""
        @Presents var breedDetails: BreedDetails.State?

        var filteredBreeds: [Breed] {
            guard !searchText.isEmpty else { return breeds }
            return breeds.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        public init() {}
    }

    public enum Action {
        case breedButtonTapped(id: String)
        case breedsResponse(page: Int, Result<[Breed], Error>)
        case breedDetails(PresentationAction<BreedDetails.Action>)
        case loadMoreBreeds
        case onAppear
        case favoriteButtonTapped(id: String)
        case retryButtonTapped
        case searchTextChanged(String)
        case tabSelected(Tab)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .breedButtonTapped(id):
                guard let breed = state.breeds.first(where: { $0.id == id }) else {
                    return .none
                }
                state.breedDetails = BreedDetails.State(breed: breed)
                return .none

            case let .breedsResponse(page, .success(breeds)):
                guard page == state.pendingPage else {
                    return .none
                }

                if page == 0 {
                    state.breeds = Self.uniquedBreeds(from: breeds)
                    state.currentPage = 0
                } else {
                    state.breeds = Self.mergingPage(
                        page: breeds,
                        into: state.breeds
                    )
                    state.currentPage = page
                }
                state.hasLoadedBreeds = true
                state.isLoading = false
                state.isLoadingMore = false
                state.hasError = false
                state.hasMorePages = breeds.count >= BreedsList.pageSize
                state.pendingPage = nil

                if let selectedID = state.breedDetails?.breed.id,
                   let updatedBreed = state.breeds.first(where: { $0.id == selectedID }) {
                    state.breedDetails = BreedDetails.State(breed: updatedBreed)
                }

                return .none

            case let .breedsResponse(page, .failure):
                guard page == state.pendingPage else {
                    return .none
                }

                state.isLoading = false
                state.isLoadingMore = false
                state.hasError = true
                state.pendingPage = nil
                return .none

            case .breedDetails(.presented(.favoriteButtonTapped)):
                guard let id = state.breedDetails?.breed.id else {
                    return .none
                }
                return self.persistFavoriteToggle(&state, id: id)

            case .breedDetails:
                return .none

            case .loadMoreBreeds:
                guard !state.isLoading, !state.isLoadingMore, state.hasMorePages else {
                    return .none
                }

                state.isLoadingMore = true
                let page = state.currentPage + 1
                state.pendingPage = page
                return self.fetchBreedsPage(page: page, state: &state)

            case .onAppear:
                guard !state.hasLoadedBreeds, !state.isLoading else {
                    return .none
                }

                state.isLoading = true
                state.pendingPage = 0
                return self.fetchBreedsPage(page: 0, state: &state)

            case .retryButtonTapped:
                state.hasError = false
                state.hasLoadedBreeds = false
                state.currentPage = 0
                state.hasMorePages = true
                state.breeds = []
                state.isLoading = false
                state.isLoadingMore = false
                state.pendingPage = nil
                return .send(.onAppear)

            case let .favoriteButtonTapped(id):
                return self.persistFavoriteToggle(&state, id: id)

            case let .searchTextChanged(text):
                state.searchText = text
                return .none

            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            }
        }
        .ifLet(\.$breedDetails, action: \.breedDetails) {
            BreedDetails()
        }
    }
}

private extension BreedsList {
    func fetchBreedsPage(page: Int, state: inout State) -> Effect<Action> {
        let fetchBreeds = self.breedsService.fetchBreeds
        let fetchCachedBreeds = self.breedsCacheClient.fetchBreeds
        let saveBreeds = self.breedsCacheClient.saveBreeds
        let pageSize = BreedsList.pageSize
        return .run { send in
            do {
                let breeds = try await fetchBreeds(pageSize, page)
                let cachedBreeds = await withErrorReporting { try await fetchCachedBreeds() } ?? []
                let favoriteBreedIDs = Self.favoriteBreedIDs(from: cachedBreeds)
                let mergedBreeds = Self.mergingFavorites(
                    in: breeds,
                    favoriteBreedIDs: favoriteBreedIDs
                )
                await withErrorReporting { try await saveBreeds(mergedBreeds) }
                await send(.breedsResponse(page: page, .success(mergedBreeds)))
            } catch {
                if page == 0 {
                    let cachedBreeds = await withErrorReporting { try await fetchCachedBreeds() } ?? []
                    if !cachedBreeds.isEmpty {
                        await send(.breedsResponse(page: page, .success(cachedBreeds)))
                    } else {
                        await send(.breedsResponse(page: page, .failure(error)))
                    }
                } else {
                    await send(.breedsResponse(page: page, .failure(error)))
                }
            }
        }
    }

    func persistFavoriteToggle(_ state: inout State, id: Breed.ID) -> Effect<Action> {
        guard let isFavorite = Self.toggleFavorite(&state, id: id) else {
            return .none
        }

        let updateFavoriteBreed = self.breedsCacheClient.updateFavoriteBreed
        return .run { _ in
            await withErrorReporting { try await updateFavoriteBreed(id, isFavorite) }
        }
    }

    static func favoriteBreedIDs(from cachedBreeds: [Breed]) -> Set<Breed.ID> {
        Set(cachedBreeds.filter(\.isFavorite).map(\.id))
    }

    static func mergingFavorites(
        in breeds: [Breed],
        favoriteBreedIDs: Set<Breed.ID>
    ) -> [Breed] {
        breeds.map { breed in
            var breed = breed
            breed.isFavorite = favoriteBreedIDs.contains(breed.id)
            return breed
        }
    }

    static func uniquedBreeds(from breeds: [Breed]) -> [Breed] {
        Self.mergingPage(page: breeds, into: [])
    }

    static func mergingPage(
        page breeds: [Breed],
        into existingBreeds: [Breed]
    ) -> [Breed] {
        var mergedBreeds = existingBreeds
        var indicesByID = Dictionary(
            uniqueKeysWithValues: mergedBreeds.enumerated().map { ($0.element.id, $0.offset) }
        )

        for breed in breeds {
            if let index = indicesByID[breed.id] {
                mergedBreeds[index] = breed
            } else {
                indicesByID[breed.id] = mergedBreeds.endIndex
                mergedBreeds.append(breed)
            }
        }

        return mergedBreeds
    }

    @discardableResult
    static func toggleFavorite(_ state: inout State, id: Breed.ID) -> Bool? {
        guard let index = state.breeds.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        state.breeds[index].isFavorite.toggle()
        let isFavorite = state.breeds[index].isFavorite

        if state.breedDetails?.breed.id == id {
            state.breedDetails?.breed.isFavorite = isFavorite
        }

        return isFavorite
    }
}
