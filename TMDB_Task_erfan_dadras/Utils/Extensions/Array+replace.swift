//
//  Array+replace.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

public extension Array {
    /// Replaces an existing element or appends a new one based on a keyPath match
    /// - Parameters:
    ///   - item: The element to replace or append
    ///   - keyPath: KeyPath to the property used for matching
    mutating func replaceOrAppend<Value>(_ item: Element,
                                         firstMatchingKeyPath keyPath: KeyPath<Element, Value>)
    where Value: Equatable
    {
        let itemValue = item[keyPath: keyPath]
        replaceOrAppend(item, whereFirstIndex: { $0[keyPath: keyPath] == itemValue })
    }
    
    /// Replaces an existing element or appends a new one based on a custom predicate
    /// - Parameters:
    ///   - item: The element to replace or append
    ///   - predicate: Closure that returns true for the element to replace
    mutating func replaceOrAppend(_ item: Element, whereFirstIndex predicate: (Element) -> Bool) {
        if let idx = self.firstIndex(where: predicate){
            self[idx] = item
        } else {
            append(item)
        }
    }
}

extension Array where Element: Hashable {
    /// Removes duplicate elements from the array while preserving order
    /// Uses a Set to track seen elements for efficient duplicate detection
    mutating func removingDuplicates() {
        var seen = Set<Element>()
        self = self.filter { seen.insert($0).inserted }
    }
}
