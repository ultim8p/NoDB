//
//  File.swift
//  
//
//  Created by Guerson on 2020-07-21.
//

import Foundation
import BinarySearch

public extension Array where Element == [String: Any] {
    func binarySearch(withIndex index: Any, key: String, value: Any) -> (obj: Element, index: Int)? {
        guard let searchResult = binarySearchAll(key: key, value: value) else { return nil }
        guard let lowerIndex = searchResult.lowerIndex,
            let upperIndex = searchResult.upperIndex else { return nil }
        for i in lowerIndex...upperIndex {
            let element = self[i]
            let comparisonResult = element.compare(to: index, key: NoDBConstant.index.rawValue)
            if comparisonResult == .equal {
                return (element, i)
            }
        }
        return nil
    }
}
