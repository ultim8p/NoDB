//
//  File.swift
//  
//
//  Created by Guerson on 2020-07-21.
//

import Foundation
import BinarySearch

extension Array where Element == [String: Any] {
    mutating func upsert(_ obj: Element, key: String) {
        guard let value = obj[key] else { return }
        let indexQ = self.binarySearch(key: key, value: value)
        if let itemIndex = indexQ.currentIndex {
            self[itemIndex] = obj
        } else if let insertIndex = indexQ.insertInIndex {
            self.insert(obj, at: insertIndex)
        }
    }
}
