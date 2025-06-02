//
//  SafeAreaInsetsKey.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import SwiftUI

/// Environment key for accessing safe area insets throughout the app
/// Note: This uses deprecated UIApplication.shared.windows approach
private struct SafeAreaInsetsKey: EnvironmentKey {
    /// Default safe area insets from the first window
    /// Warning: This approach is deprecated in iOS 15+
    static var defaultValue: UIEdgeInsets {
        UIApplication.shared.windows[0].safeAreaInsets
    }
}

public extension EnvironmentValues {
    /// Provides access to safe area insets via SwiftUI environment
    /// Usage: @Environment(\.safeAreaInsets) var safeAreaInsets
    var safeAreaInsets: UIEdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    /// Converts UIEdgeInsets to SwiftUI EdgeInsets
    /// - Returns: EdgeInsets with corresponding values
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

public extension UIEdgeInsets {
    /// Calculates appropriate bottom padding considering safe area
    /// - Parameter value: Minimum padding value desired
    /// - Returns: The larger of safe area bottom inset or the provided value
    func bottomPadding(value: CGFloat) -> CGFloat {
        if insets.bottom >= value {
            return insets.bottom
        } else {
            return value
        }
    }
}
