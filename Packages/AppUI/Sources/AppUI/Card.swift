import SwiftUI

public struct Card<Content: View>: View {
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        self.content
            .padding(AppTheme.Layout.screenPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.Colors.panelBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppTheme.Layout.cardCornerRadius,
                    style: .continuous
                )
            )
    }
}
