//
//  Comparable+Upsert.swift
//  RIDB
//
//  Created by Guerson on 2020-05-23.
//  Copyright © 2020 rise. All rights reserved.
//

import Foundation
import BinarySearch

extension Array where Element: Comparable {
    
    mutating func insert(_ obj: Element) {
        let indexTuple = self.binarySearch(obj)
        if let insertIndex = indexTuple.currentIndex ?? indexTuple.insertInIndex {
            self.insert(obj, at: insertIndex)
        }
    }
    
    mutating func upsert(_ obj: Element) {
        let indexQ = binarySearch(obj)
        if let itemIndex = indexQ.currentIndex {
            self[itemIndex] = obj
        } else if let insertIndex = indexQ.insertInIndex {
            self.insert(obj, at: insertIndex)
        }
    }
    
}

extension Array where Element == [String: Any] {
    mutating func insert(_ indexDict: Element, key: String) {
        guard let value = indexDict[key] else { return }
        let indexQ = self.binarySearch(key: key, value: value)
        if let insertIndex = indexQ.currentIndex ?? indexQ.insertInIndex {
            self.insert(indexDict, at: insertIndex)
        }
    }
    
    mutating func upsert(_ obj: Element, key: String) {
        guard let value = obj[key] else { return }
        let indexQ = self.binarySearch(key: key, value: value)
        if let itemIndex = indexQ.currentIndex {
            self[itemIndex] = obj
        } else if let insertIndex = indexQ.insertInIndex {
            self.insert(obj, at: insertIndex)
        }
    }
    
    mutating func delete(_ obj: Element, key: String) {
        guard let value = obj[key], let index = obj["index"] else { return }
        let indexQ = self.binarySearch(withIndex: index, key: key, value: value)
        if let itemIndex = indexQ?.index {
            self.remove(at: itemIndex)
        }
    }
}

