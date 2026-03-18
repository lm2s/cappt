import ComposableArchitecture
import DesignKit
import SwiftUI

public struct BreedsView: View {
    let store: StoreOf<BreedsFeature>
    
    public init(store: StoreOf<BreedsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Breeds")
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.accent)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(AppTheme.Colors.accent)
            }
            .padding(AppTheme.Layout.screenPadding)
        }
        .onAppear {
            self.store.send(.onAppear)
        }
    }
}

#Preview {
    BreedsView(
        store: Store(initialState: BreedsFeature.State()) {
            BreedsFeature()
        }
    )
}
