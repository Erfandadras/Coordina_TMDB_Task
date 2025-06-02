//
//  Coordinator.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//


import Combine
import SwiftUI

public class Coordinator: ObservableObject {
    // MARK: - properties
    @Published public var navigationPath = NavigationPath()
    
    // MARK: - init
    public init() {}
    
    // MARK: - logics
    public func append<T>(_ path: T) where T : Hashable {
        navigationPath.append(path)
    }
    
    public func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    public func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
