import ComposableArchitecture
import PersistenceKit

@Reducer
public struct BreedDetails {
    @ObservableState
    public struct State: Equatable {
        public var breed: Breed
        
        public init(breed: Breed) {
            self.breed = breed
        }
    }
    
    public enum Action {
        case favoriteButtonTapped
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .favoriteButtonTapped:
                return .none
            }
        }
    }
}
