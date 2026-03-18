import ComposableArchitecture

@Reducer
public struct BreedsFeature {
    @ObservableState
    public struct State {
        var breeds = Breed.mock
        
        public init() {}
        
        struct Breed: Equatable, Identifiable {
            let id: String
            let name: String
            let isFavorite: Bool
            
            static let mock: [Self] = [
                Self(id: "abyssinian", name: "Abyssinian", isFavorite: false),
                Self(id: "bengal", name: "Bengal", isFavorite: true),
                Self(id: "british-shorthair", name: "British Shorthair", isFavorite: false),
                Self(id: "devon-rex", name: "Devon Rex", isFavorite: false),
                Self(id: "maine-coon", name: "Maine Coon", isFavorite: true),
                Self(id: "norwegian-forest", name: "Norwegian Forest", isFavorite: false),
                Self(id: "persian", name: "Persian", isFavorite: true),
                Self(id: "ragdoll", name: "Ragdoll", isFavorite: false),
                Self(id: "russian-blue", name: "Russian Blue", isFavorite: true),
                Self(id: "scottish-fold", name: "Scottish Fold", isFavorite: false),
                Self(id: "siamese", name: "Siamese", isFavorite: true),
                Self(id: "sphynx", name: "Sphynx", isFavorite: false),
            ]
        }
    }
    
    public enum Action {
        case onAppear
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
