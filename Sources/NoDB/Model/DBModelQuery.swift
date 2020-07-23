//
//  File.swift
//  
//
//  Created by Guerson Perez on 22/07/20.
//

import Foundation
import BinarySearch

// RangeIndexes
public extension Array where Element == [String: Any] {
    /// Find the start index in the array with a skip count.
    /// Validates that the start index is still within the array.
    /// - Parameters:
    ///     - skip: Count to skip from the starting index.
    /// - Returns: Valid index after skipping the count.
    func startIndex(skip: Int?) -> Int {
        var startIndex = 0
        startIndex += skip ?? 0
        return Swift.min(startIndex, self.count - 1)
    }
    func endIndex(skip: Int?, limit: Int?) -> Int {
        let maxIndex = self.count - 1
        var end = maxIndex
        if let limit = limit {
            let start = startIndex(skip: skip)
            end = start + limit
            end = Swift.min(end, maxIndex)
        }
        return end
    }
    func range(skip: Int?, limit: Int?) -> [[String: Any]]? {
        let startRange = startIndex(skip: skip)
        let endRange = endIndex(skip: skip, limit: limit)
        guard startRange <= endRange else { return nil }
        return range(start: startRange, end: endRange)
    }
    func range(start: Int, end: Int) -> [[String: Any]]? {
        return Array(self[start...end])
    }
}

public extension Array where Element: DBModel {
    /// Find the start index in the array with a skip count.
    /// Validates that the start index is still within the array.
    /// - Parameters:
    ///     - skip: Count to skip from the starting index.
    /// - Returns: Valid index after skipping the count.
    func startIndex(skip: Int?) -> Int {
        var startIndex = 0
        startIndex += skip ?? 0
        return Swift.min(startIndex, self.count - 1)
    }
    func endIndex(skip: Int?, limit: Int?) -> Int {
        let maxIndex = self.count - 1
        var end = maxIndex
        if let limit = limit {
            let start = startIndex(skip: skip)
            end = start + limit
            end = Swift.min(end, maxIndex)
        }
        return end
    }
    func range(skip: Int?, limit: Int?) -> [Element]? {
        let startRange = startIndex(skip: skip)
        let endRange = endIndex(skip: skip, limit: limit)
        guard startRange <= endRange else { return nil }
        return range(start: startRange, end: endRange)
    }
    func range(start: Int, end: Int) -> [Element]? {
        return Array(self[start...end])
    }
}

// MARK: Sort
public extension Array where Element: DBModel {
    mutating func sort(_ sort: Sort) {
        self.sort { (obj1, obj2) -> Bool in
            let dict1 = obj1.toDictionary()
            let dict2 = obj2.toDictionary()
            if let val2 = dict2[sort.key] {
                let compare = dict1.compare(to: val2, key: sort.key)
                switch sort.order {
                case .ascending:
                    return compare == .lower
                case .descending:
                    return compare == .greater
                }
            }
            return false
        }
    }
}

public extension Array where Element: DBModel {
//    func find<Q: QueryUnion>(_ queryUnion: Q) -> [Element]? {
//
//    }
    
    /// Finds a list of objects using a single query.
    /// - Parameters:
    ///     - query: Query to execute to find objects
    ///     - dbName: Name of the Database to perform the query on.
    ///
    func find(_ query: Query?, dbName: String, sort: Sort? = nil, skip: Int? = nil, limit: Int? = nil, idKey: String) -> [Element]? {
        guard let queryIndexes = findIndexes(for: query, dbName: dbName, idKey: idKey) else { return nil }
        return getElemetResults(for: queryIndexes, sort: sort, skip: skip, limit: limit)
    }
    
    private func getElemetResults(for queryIndexes: [[String: Any]], sort: Sort?, skip: Int? = nil, limit: Int? = nil) -> [Element]? {
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
    
    /// Finds a list of indexes based on a Query object.
    /// - Parameters:
    ///     - query: Query containing search parameters to find the list of indexes.
    ///     - dbName: Name of the database to perform the query on.
    /// - Returns: List of index dictionaries that matched the query.
    private func findIndexes(for query: Query?, dbName: String, idKey: String) -> [[String: Any]]? {
        guard var key = query?.key,
            let val = query?.value,
            let op = query?.op else {
                // If query has no properties, find all
                let indexDBName = dbName + ":" + NoDBConstant.id.rawValue
                return IndexesManager.shared.get(withType: .indexes, indexDBName: indexDBName)
        }
        // If query is performed over the id of the object, change it to use local noDBId key.
        if key == idKey { key = NoDBConstant.id.rawValue }
        
        let indexDBName = dbName + ":" + key
        guard let indexes = IndexesManager.shared.get(withType: .indexes, indexDBName: indexDBName) else { return nil }
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
    
//    func find<Q: QueryUnion>(with key: String, lowerValue: Any, lowerOpt: LowerOperator, upperValue: Any, upperOpt: UpperOperator, limit: Int?, bound: Bound) -> [Element]? {
//       let indexDBName = Element.dbName + ":" + key
//       guard let indexes = IndexesManager.shared.indexes[indexDBName] else { return nil }
//       guard let indexsResults = indexes.searchRange(with: key, lowerValue: lowerValue, lowerOpt: lowerOpt, upperValue: upperValue, upperOpt: upperOpt, limit: limit, bound: bound) else { return nil}
//       return getObjects(for: indexsResults)
//   }
}



//public func ==(lhs: String, rhs: Primitive?) -> Document {
//    return [
//        lhs: [
//            "$eq": rhs ?? Null()
//        ] as Document
//    ]
//}
