//
//  View+placeholder+anchor.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import SwiftUI

extension View {
    /// Shows a placeholder view when a condition is met
    /// - Parameters:
    ///   - shouldShow: Boolean condition to show/hide placeholder
    ///   - alignment: Alignment of the placeholder within the ZStack
    ///   - placeholder: ViewBuilder closure that creates the placeholder view
    /// - Returns: A view with the placeholder overlaid when condition is true
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
    
    /// Aligns the view to the leading edge by adding a trailing Spacer
    /// - Returns: View wrapped in HStack with trailing Spacer
    func leading() -> some View {
        HStack {
            self
            Spacer()
        }
    }
    
    /// Aligns the view to the trailing edge by adding a leading Spacer
    /// - Returns: View wrapped in HStack with leading Spacer
    func trailing() -> some View {
        HStack {
            Spacer()
            self
        }
    }
}
