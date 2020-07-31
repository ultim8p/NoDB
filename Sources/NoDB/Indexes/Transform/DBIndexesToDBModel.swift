//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

public extension Array where Element: DBModel {
    func getElementResults(for queryIndexes: [[String: Any]], sort: Sort?, skip: Int? = nil, limit: Int? = nil) -> [Element]? {
        // If sort parameter exists, get the list of elements first to sort them before performing the skip and limit operations.
        if let sort = sort {
            var objs = models(fromIndexes: queryIndexes)
            objs?.sort(sort)
            return objs?.range(skip: skip, limit: limit)
        } else {
            let rangedIndexes = queryIndexes.range(skip: skip, limit: limit)
            return models(fromIndexes: rangedIndexes)
        }
    }
    
    func getElementResult(for queryIndex: [String: Any]?) -> Element? {
        return model(fromIndex: queryIndex)
    }
}
