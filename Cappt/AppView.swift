import BreedsFeature
import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        BreedsView(
            store: self.store.scope(state: \.breeds, action: \.breeds)
        )
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
