//
//  File.swift
//  
//
//  Created by Guerson on 2020-07-21.
//

import Foundation
import BinarySearch

extension Array where Element == [String: Any] {
    /// Inserts a dictionary in an array of dictionaries that are ordered by a specified key.
    /// - Parameters:
    ///     - key: Key in which the array of dictionaries are ordered by.
    mutating func insert(_ indexDict: Element, key: String) {
        guard let value = indexDict[key] else { return }
        let indexQ = self.binarySearch(key: key, value: value)
        if let insertIndex = indexQ.currentIndex ?? indexQ.insertInIndex, self.canInsert(at: insertIndex) {
            self.insert(indexDict, at: insertIndex)
        }
    }
}
