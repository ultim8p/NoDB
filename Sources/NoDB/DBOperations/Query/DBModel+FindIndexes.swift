//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

extension Array where Element: DBModel {
    /// Finds a list of indexes based on a Query object.
    /// - Parameters:
    ///     - query: Query containing search parameters to find the list of indexes.
    ///     - dbName: Name of the database to perform the query on.
    /// - Returns: List of index dictionaries that matched the query.
    func findIndexes(for query: Query?, dbName: String, idKey: String, indexesManager: IndexesManager) -> [[String: Any]]? {
        guard var key = query?.key,
            let val = query?.value,
            let op = query?.op else {
                // If query has no properties, find all
                let indexDBName = dbName + ":" + NoDBConstant.id.rawValue
            return indexesManager.get(withType: .indexes, indexDBName: indexDBName)
        }
        // If query is performed over the id of the object, change it to use local noDBId key.
        if key == idKey { key = NoDBConstant.id.rawValue }
        
        let indexDBName = dbName + ":" + key
        guard let indexes = indexesManager.get(withType: .indexes, indexDBName: indexDBName) else { return nil }
        switch op {
        case .equal:
            let result = indexes.binarySearchAll(key: key, value: val)
            return result?.results
        case .greaterThan:
            return indexes.searchRange(with: key, value: val, withOp: .greater, limit: nil)
        case .greaterThanOrEqual:
            return indexes.searchRange(with: key, value: val, withOp: .greaterOrequal)
        case .lowerThan:
            return indexes.searchRange(with: key, value: val, withOp: .lower, limit: nil)
        case .lowerThanOrEqual:
            return indexes.searchRange(with: key, value: val, withOp: .lowerOrequal)
        }
    }
}
