//
//  CustomError.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

/// Protocol extending LocalizedError to include a title property
protocol ErrorProtocol: LocalizedError {
    var title: String? { get }
}

/// Custom error type for application-specific error handling
struct CustomError: ErrorProtocol {

    /// Optional title for the error (used in UI alerts)
    var title: String?
    /// Error description for user display
    var errorDescription: String? { return _description }
    /// Failure reason (same as description for consistency)
    var failureReason: String? { return _description }
    /// Private storage for the error description
    private var _description: String

    /// Initializes a custom error with title and description
    /// - Parameters:
    ///   - title: Error title (defaults to generic message)
    ///   - description: Detailed error description
    init(title: String = "Something wrong happened!",
         description: String) {
        self.title = title
        self._description = description
    }
    
}
