import BreedsFeature
import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var breeds = BreedsFeature.State()
    }
    
    enum Action {
        case breeds(BreedsFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.breeds, action: \.breeds) {
            BreedsFeature()
        }
    }
}
