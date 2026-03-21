import BreedsFeature
import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var breeds = BreedsList.State()
    }

    enum Action {
        case breeds(BreedsList.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.breeds, action: \.breeds) {
            BreedsList()
        }
    }
}
