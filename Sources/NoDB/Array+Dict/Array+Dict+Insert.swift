//
//  File.swift
//  
//
//  Created by Guerson on 2020-07-21.
//

import Foundation
import BinarySearch

extension Array where Element == [String: Any] {
    mutating func insert(_ indexDict: Element, key: String) {
        guard let value = indexDict[key] else { return }
        let indexQ = self.binarySearch(key: key, value: value)
        if let insertIndex = indexQ.currentIndex ?? indexQ.insertInIndex {
            self.insert(indexDict, at: insertIndex)
        }
    }
}
