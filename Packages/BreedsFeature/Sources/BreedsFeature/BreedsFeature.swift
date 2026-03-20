import BreedDetails
import ComposableArchitecture
import PersistenceKit

@Reducer
public struct BreedsFeature {
    @Dependency(\.breedsService) var breedsService
    @Dependency(\.breedsCacheClient) var breedsCacheClient

    @ObservableState
    public struct State: Equatable {
        var hasLoadedBreeds = false
        var breeds = Breed.mock
        var isLoading = false
        @Presents var breedDetails: BreedDetails.State?

        public init() {}
    }

    public enum Action {
        case breedButtonTapped(id: String)
        case breedsResponse(Result<[Breed], Error>)
        case breedDetails(PresentationAction<BreedDetails.Action>)
        case onAppear
        case favoriteButtonTapped(id: String)
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

            case let .breedsResponse(.success(breeds)):
                state.breeds = breeds
                state.hasLoadedBreeds = true
                state.isLoading = false

                if let selectedID = state.breedDetails?.breed.id,
                   let updatedBreed = breeds.first(where: { $0.id == selectedID }) {
                    state.breedDetails = BreedDetails.State(breed: updatedBreed)
                }

                return .none

            case .breedsResponse(.failure):
                state.isLoading = false
                return .none

            case .breedDetails(.presented(.favoriteButtonTapped)):
                guard let id = state.breedDetails?.breed.id else {
                    return .none
                }
                return self.persistFavoriteToggle(&state, id: id)

            case .breedDetails:
                return .none

            case .onAppear:
                guard !state.hasLoadedBreeds, !state.isLoading else {
                    return .none
                }

                state.isLoading = true
                let fetchBreeds = self.breedsService.fetchBreeds
                let fetchCachedBreeds = self.breedsCacheClient.fetchBreeds
                let saveBreeds = self.breedsCacheClient.saveBreeds
                return .run { send in
                    do {
                        let breeds = try await fetchBreeds()
                        let cachedBreeds = (try? await fetchCachedBreeds()) ?? []
                        let favoriteBreedIDs = Self.favoriteBreedIDs(from: cachedBreeds)
                        let mergedBreeds = Self.mergingFavorites(
                            in: breeds,
                            favoriteBreedIDs: favoriteBreedIDs
                        )
                        try? await saveBreeds(mergedBreeds)
                        await send(.breedsResponse(.success(mergedBreeds)))
                    } catch {
                        let cachedBreeds = (try? await fetchCachedBreeds()) ?? []
                        if !cachedBreeds.isEmpty {
                            await send(.breedsResponse(.success(cachedBreeds)))
                        } else {
                            await send(.breedsResponse(.failure(error)))
                        }
                    }
                }

            case let .favoriteButtonTapped(id):
                return self.persistFavoriteToggle(&state, id: id)
            }
        }
        .ifLet(\.$breedDetails, action: \.breedDetails) {
            BreedDetails()
        }
    }
}

private extension BreedsFeature {
    func persistFavoriteToggle(_ state: inout State, id: Breed.ID) -> Effect<Action> {
        guard let isFavorite = Self.toggleFavorite(&state, id: id) else {
            return .none
        }

        let updateFavoriteBreed = self.breedsCacheClient.updateFavoriteBreed
        return .run { _ in
            try? await updateFavoriteBreed(id, isFavorite)
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