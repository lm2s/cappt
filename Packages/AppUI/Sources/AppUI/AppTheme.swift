import SwiftUI
import UIKit

public enum AppTheme {
    public enum Colors {
        public static let accent = Color(red: 0.15, green: 0.38, blue: 0.28)
        public static let background = Color(uiColor: .systemGroupedBackground)
        public static let panelBackground = Color(uiColor: .secondarySystemGroupedBackground)
        public static let secondaryText = Color(uiColor: .secondaryLabel)
    }
    
    public enum Layout {
        public static let cardCornerRadius: CGFloat = 24
        public static let screenPadding: CGFloat = 24
    }
}
