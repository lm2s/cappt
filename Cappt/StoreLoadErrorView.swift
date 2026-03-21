import SwiftUI

struct StoreLoadErrorView: View {
    let errorDescription: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)
                .accessibilityIdentifier("store-error-icon")

            Text("Something Went Wrong")
                .font(.title)
                .fontWeight(.bold)
                .accessibilityIdentifier("store-error-title")

            Text("The app was unable to load its data. Please contact customer service for assistance.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("store-error-body")

            Spacer()

            Text(errorDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("store-error-details")
        }
        .padding(32)
    }
}

#Preview {
    StoreLoadErrorView(errorDescription: "Failed to load Core Data store: The file couldn't be opened.")
}
