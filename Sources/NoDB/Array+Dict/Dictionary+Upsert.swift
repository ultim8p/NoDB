//
//  File.swift
//  
//
//  Created by Guerson on 2020-07-21.
//

import Foundation
import BinarySearch

extension Array where Element == [String: Any] {
    
    /// Replaces an object if it aleady existed and inserts it if it didn't exist yet.
    /// - Parameters:
    ///     - dict: Dictionary to either insert or replace.
    ///     - key: Key to chech wheather the value already existed.
    @discardableResult
    mutating func upsert(_ dict: Element, key: String) -> (currentIndex: Int?, insertingIndex: Int?)? {
        guard let value = dict[key] else { return nil }
        let indexQ = self.binarySearch(key: key, value: value)
        if let itemIndex = indexQ.currentIndex {
            self[itemIndex] = dict
            return (itemIndex, nil)
        } else if let insertIndex = indexQ.insertInIndex, self.canInsert(at: insertIndex) {
            self.insert(dict, at: insertIndex)
            return (nil, insertIndex)
        }
        return nil
    }
}
