import BreedDetails
import ComposableArchitecture

@Reducer
public struct BreedsFeature {
    @ObservableState
    public struct State {
        var breeds = Breed.mock
        @Presents var breedDetails: BreedDetails.State?
        
        public init() {}
    }
    
    public enum Action {
        case breedButtonTapped(id: String)
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
                
            case .breedDetails(.presented(.favoriteButtonTapped)):
                guard let id = state.breedDetails?.breed.id else {
                    return .none
                }
                Self.toggleFavorite(&state, id: id)
                return .none
                
            case .breedDetails:
                return .none
                
            case .onAppear:
                return .none
                
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
