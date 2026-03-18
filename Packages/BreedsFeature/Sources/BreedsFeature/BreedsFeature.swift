import ComposableArchitecture

@Reducer
public struct BreedsFeature {
    @ObservableState
    public struct State {
        public init() {}
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
