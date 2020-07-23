//
//  File.swift
//  
//
//  Created by Guerson Perez on 22/07/20.
//

import Foundation
import BinarySearch

// RangeIndexes
public extension Array where Element == [String: Any] {
    /// Find the start index in the array with a skip count.
    /// Validates that the start index is still within the array.
    /// - Parameters:
    ///     - skip: Count to skip from the starting index.
    /// - Returns: Valid index after skipping the count.
    func startIndex(skip: Int?) -> Int {
        var startIndex = 0
        startIndex += skip ?? 0
        return Swift.min(startIndex, self.count - 1)
    }
    func endIndex(skip: Int?, limit: Int?) -> Int {
        let maxIndex = self.count - 1
        var end = maxIndex
        if let limit = limit {
            let start = startIndex(skip: skip)
            end = start + limit
            end = Swift.min(end, maxIndex)
        }
        return end
    }
    func range(skip: Int?, limit: Int?) -> [[String: Any]]? {
        let startRange = startIndex(skip: skip)
        let endRange = endIndex(skip: skip, limit: limit)
        guard startRange <= endRange else { return nil }
        return range(start: startRange, end: endRange)
    }
    func range(start: Int, end: Int) -> [[String: Any]]? {
        return Array(self[start...end])
    }
}

public extension Array where Element: DBModel {
    /// Find the start index in the array with a skip count.
    /// Validates that the start index is still within the array.
    /// - Parameters:
    ///     - skip: Count to skip from the starting index.
    /// - Returns: Valid index after skipping the count.
    func startIndex(skip: Int?) -> Int {
        var startIndex = 0
        startIndex += skip ?? 0
        return Swift.min(startIndex, self.count - 1)
    }
    func endIndex(skip: Int?, limit: Int?) -> Int {
        let maxIndex = self.count - 1
        var end = maxIndex
        if let limit = limit {
            let start = startIndex(skip: skip)
            end = start + limit
            end = Swift.min(end, maxIndex)
        }
        return end
    }
    func range(skip: Int?, limit: Int?) -> [Element]? {
        let startRange = startIndex(skip: skip)
        let endRange = endIndex(skip: skip, limit: limit)
        guard startRange <= endRange else { return nil }
        return range(start: startRange, end: endRange)
    }
    func range(start: Int, end: Int) -> [Element]? {
        return Array(self[start...end])
    }
}

// MARK: Sort
public extension Array where Element: DBModel {
    mutating func sort(_ sort: Sort) {
        self.sort { (obj1, obj2) -> Bool in
            let dict1 = obj1.toDictionary()
            let dict2 = obj2.toDictionary()
            if let val2 = dict2[sort.key] {
                let compare = dict1.compare(to: val2, key: sort.key)
                switch sort.order {
                case .ascending:
                    return compare == .lower
                case .descending:
                    return compare == .greater
                }
            }
            return false
        }
    }
}

