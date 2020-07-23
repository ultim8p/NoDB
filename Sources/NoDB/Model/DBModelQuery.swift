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

public struct Query {
    var op: Operator?
    var key: String?
    var value: Any?
}

public func ==(lhs: String, rhs: Any) -> Query {
    return Query(op: .equal, key: lhs, value: rhs)
}
public func >(lhs: String, rhs: Any) -> Query {
    return Query(op: .greater, key: lhs, value: rhs)
}
public func <(lhs: String, rhs: Any) -> Query {
    return Query(op: .lower, key: lhs, value: rhs)
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

extension Array where Element: DBModel {
//    func find<Q: QueryUnion>(_ queryUnion: Q) -> [Element]? {
//
//    }
    
    func findIndexes(for query: Query) {
        guard let key = query.key,
            let val = query.value,
            let op = query.op else { return }
        let indexDBName = Element.dbName + ":" + key
        guard let indexes = IndexesManager.shared.indexes[indexDBName] else { return nil }
        let indexesResults = indexes.binarySearchAll(key: key, value: val)
        
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
