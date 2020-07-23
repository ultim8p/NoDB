//
//  File.swift
//  
//
//  Created by Guerson Perez on 22/07/20.
//

import Foundation
import BinarySearch

public enum SortOrder {
    case ascending
    case descending
}
public struct Sort {
    var sortKey: String
    var order: SortOrder
}

public struct ResultCursor {
    var result: [Int]
    
}

public protocol QueryUnion {
    var queries: [Query]? { get set }
}
public struct QueryOr: QueryUnion {
    public var queries: [Query]?
}
public struct QueryAnd: QueryUnion {
    public var queries: [Query]?
}

enum QueryOperator {
    case equal
    case greaterThan
    case greaterThanOrEqual
    case lowerThan
    case lowerThanOrEqual
}

public struct Query {
    var op: QueryOperator?
    var key: String?
    var value: Any?
    
    static func all() -> Query {
        return Query()
    }
}

public func ==(lhs: String, rhs: Any) -> Query {
    return Query(op: .equal, key: lhs, value: rhs)
}
public func >(lhs: String, rhs: Any) -> Query {
    return Query(op: .greaterThan, key: lhs, value: rhs)
}
public func <(lhs: String, rhs: Any) -> Query {
    return Query(op: .lowerThan, key: lhs, value: rhs)
}

public func &&(lhs: Query, rhs: Query) -> QueryAnd {
    return QueryAnd(queries: [lhs, rhs])
}

public func &&(lhs: QueryAnd, rhs: Query) -> QueryAnd {
    var andQuery = lhs
    var queries = andQuery.queries ?? []
    queries.append(rhs)
    andQuery.queries = queries
    return andQuery
}

func testQuery() {
    
    let query = "age" == 24 && "hairColor" == "black" && "dateCreated" == Date()
    
    
}

public extension Array where Element == [String: Any] {
    func startIndex(skip: Int?) -> Int {
        var startIndex = 0
        startIndex += skip ?? 0
        return Swift.min(startIndex, self.count - 1)
    }
    func endIndex(limit: Int?, skip: Int?) -> Int {
        let maxIndex = self.count - 1
        var end = maxIndex
        if let limit = limit {
            let start = startIndex(skip: skip)
            end = start + limit
            end = Swift.min(end, maxIndex)
        }
        return end
    }
    func range(start: Int, end: Int) -> [[String: Any]]? {
        return Array(self[start...end])
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
    public func find(_ query: Query, dbName: String, limit: Int? = nil, skip: Int? = nil) -> [Element]? {
        guard let queryIndexes = findIndexes(for: query, dbName: dbName) else { return nil }
        
        if let limit = limit, let skip = skip {
            let startIndex = queryIndexes.startIndex(skip: skip)
            let endIndex = queryIndexes.endIndex(limit: limit, skip: skip)
            print("GOT SEARCH RANGES: [\(startIndex) ... \(endIndex)]")
            guard let limitedIndexes = queryIndexes.range(start: startIndex, end: endIndex) else { return nil }
            let objs = models(fromIndexes: limitedIndexes)
            return objs
        } else {
            return models(fromIndexes: queryIndexes)
        }
    }
    private func findIndexes(for query: Query, dbName: String) -> [[String: Any]]? {
        guard let key = query.key,
            let val = query.value,
            let op = query.op else {
                // If query has no properties, find all
                let indexDBName = dbName + ":" + "_id"
                return IndexesManager.shared.get(withType: .indexes, indexDBName: indexDBName)
        }
        
        let indexDBName = dbName + ":" + key
        guard let indexes = IndexesManager.shared.get(withType: .indexes, indexDBName: indexDBName) else { return nil }
        switch op {
        case .equal:
            let result = indexes.binarySearchAll(key: key, value: val)
            return result?.results
        case .greaterThan:
            let indexesResults = indexes.searchRange(with: key, value: val, withOp: .greater, limit: nil)
            return indexesResults
        case .greaterThanOrEqual:
            return nil
        case .lowerThan:
            let indexesResults = indexes.searchRange(with: key, value: val, withOp: .lower, limit: nil)
            return indexesResults
        case .lowerThanOrEqual:
            return nil
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
