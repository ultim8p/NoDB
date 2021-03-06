//
//  File.swift
//  
//
//  Created by Ita on 7/1/20.
//

import Foundation
import Mergeable

extension Array where Element == [String: Any] {
        
    /// Searches for a dictionary in this array and returns the value for "index" key in the dictionary.
    /// - Parameters:
    ///     - key: Name of the key to search for.
    ///     - value: Value for the key to search for.
    /// - Returns: Value of the "index" key in the dictionary.
    func indexValue(for key: String, value: Any) -> Int? {
        guard let indexedDict = indexedDict(with: key, value: value),
            let index = indexedDict[NoDBConstant.index.rawValue] as? Int else { return nil }
        return index
    }
    
    /// Returns the dictionary object of the index with this key value.
    func indexedDict(with key: String, value: Any) -> [String: Any]? {
        let objectIndexTuple = self.index(with: key, value: value)
        guard let index = objectIndexTuple.currentIndex else { return nil }
        let objectIndexDict = self[index]
        return objectIndexDict
    }
    
    /// Returns a tuple with the currentIndex of the object if found. If not found returns the index in which the object with this value should be inserted.
    func index(with key: String, value: Any) -> (currentIndex: Int?, insertInIndex: Int?) {
        let indexFound = binarySearch(key: key, value: value)
        return indexFound
    }
    
}


