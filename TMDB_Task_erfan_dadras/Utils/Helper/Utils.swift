//
//  Utils.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

/// Utility struct for accessing app version and build information
struct Utils {
    /// Private reference to the app's Info.plist dictionary
    private static let infoDict = Bundle.main.infoDictionary
    
    /// Current build number from CFBundleVersion
    /// - Returns: Build number as string, empty string if not found
    static var buildNumber: String {
        if let infoDict = infoDict {
            return infoDict["CFBundleVersion"] as? String ?? ""
        }
        return ""
    }
    
    /// Current app version from CFBundleShortVersionString
    /// - Returns: Version string (e.g., "1.0.0"), empty string if not found
    static var appVersion: String {
        if let infoDict = infoDict {
            return infoDict["CFBundleShortVersionString"] as? String ?? ""
        }
        return ""
    }
    
    /// Formatted version string combining version and build number
    /// Format: "Version X.X.X (buildNumber)"
    static let versionString = "Version \(appVersion)" + " (\(buildNumber))"
}
