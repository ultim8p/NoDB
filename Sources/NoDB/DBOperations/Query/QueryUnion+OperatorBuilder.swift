//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

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
