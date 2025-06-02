//
//  LogManager.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//


enum LogLevel: String {
    case error = "❌❌ Error", success = "✅✅ Success", info = "✏️✏️ Info", warning = "⚠️ ⚠️ Warning"
}

struct Logger {
    static func log(_ level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line, _ messages: Any...) {
        // Construct log message with source location information
        let filePart = file.components(separatedBy: "/").last ?? ""
        let logMessage = "[\(level.rawValue) >>>> on \(filePart) -> \(function) line \(line)"
        
        // Append the variadic messages to the log message
        let formattedMessage = messages.map { String(describing: $0) }.joined(separator: " + ")
        
        // Combine source location information and messages
        let finalMessage = logMessage + " msg: " + formattedMessage + "]"
        
        // Log to NSLog for local debugging
        print(finalMessage)
    }
}
