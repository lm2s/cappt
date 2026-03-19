import BreedDetails
import ComposableArchitecture

@Reducer
public struct BreedsFeature {
    @Dependency(\.breedsService) var breedsService

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
                Self.toggleFavorite(&state, id: id)
                return .none
                
            case .breedDetails:
                return .none
                
            case .onAppear:
                guard !state.hasLoadedBreeds, !state.isLoading else {
                    return .none
                }

                state.isLoading = true
                let fetchBreeds = self.breedsService.fetchBreeds
                return .run { send in
                    await send(
                        .breedsResponse(
                            Result {
                                try await fetchBreeds()
                            }
                        )
                    )
                }
                
            case let .favoriteButtonTapped(id):
                Self.toggleFavorite(&state, id: id)
                return .none
            }
        }
        .ifLet(\.$breedDetails, action: \.breedDetails) {
            BreedDetails()
        }
    }
}

private extension BreedsFeature {
    static func toggleFavorite(_ state: inout State, id: Breed.ID) {
        guard let index = state.breeds.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        state.breeds[index].isFavorite.toggle()
        let isFavorite = state.breeds[index].isFavorite
        
        if state.breedDetails?.breed.id == id {
            state.breedDetails?.breed.isFavorite = isFavorite
        }
    }
}
