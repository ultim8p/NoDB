//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

extension Array where Element: DBModel {
//    func find<Q: QueryUnion>(_ queryUnion: Q) -> [Element]? {
//
//    }
    
    /// Finds a list of objects using a single query.
    /// - Parameters:
    ///     - query: Query to execute to find objects
    ///     - dbName: Name of the Database to perform the query on.
    ///
    func find(_ query: Query?, dbName: String, sort: Sort? = nil, skip: Int? = nil, limit: Int? = nil, idKey: String, indexesManager: IndexesManager) -> [Element]? {
        guard let queryIndexes = findIndexes(for: query, dbName: dbName, idKey: idKey, indexesManager: indexesManager) else { return nil }
        return getElemetResults(for: queryIndexes, sort: sort, skip: skip, limit: limit)
    }
    
    func findFirst(_ query: Query?, dbName: String, idKey: String, indexesManager: IndexesManager) -> Element? {
        guard let queryIndexes = findIndexes(for: query, dbName: dbName, idKey: idKey, indexesManager: indexesManager) else { return nil }
        return getElementResult(for: queryIndexes)
    }
}
