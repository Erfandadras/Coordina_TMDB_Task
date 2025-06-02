//
//  BaseViewModel.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Combine
import SwiftUI

/// Represents the different states a view model can be in
enum ViewModelState: Equatable {
    /// Custom equality implementation to handle Error types
    static func == (lhs: ViewModelState, rhs: ViewModelState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.noData, .noData): return true
        case (.success, .success): return true
        case (.failure, .failure): return true
        case (.refresh, .refresh): return true
        case (.loadMore, .loadMore): return true
        default: return false
        }
    }
    
    case refresh    // Currently refreshing data
    case loading    // Loading data for the first time
    case noData     // No data available
    case success    // Data loaded successfully
    case loadMore
    case failure(error: Error)  // Error occurred during data loading
}

/// Base protocol for all view models
protocol BaseViewModelProtocol {}

/// Base view model class providing common functionality for all view models
class BaseViewModel: BaseViewModelProtocol, ObservableObject {
    
    // MARK: - Published Properties
    /// Current state of the view model, observed by UI
    @Published private(set) var state: ViewModelState?
    
    /// Set to store Combine cancellables for memory management
    var bag: Set<AnyCancellable> = []
    
    // MARK: - Public Methods
    /// Updates the view model state with animation on the main thread
    /// - Parameter state: The new state to set
    func updateState(state: ViewModelState) {
        mainThread {
            withAnimation {
                self.state = state
            }
        }
    }
    
    /// Override this method in subclasses to implement data fetching logic
    /// Base implementation does nothing
    func fetchData() {
        // Override in subclasses
    }
}
