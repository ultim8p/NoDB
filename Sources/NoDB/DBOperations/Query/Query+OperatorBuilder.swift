//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

public func ==(lhs: String, rhs: Any) -> Query {
    return Query(op: .equal, key: lhs, value: rhs)
}
public func >(lhs: String, rhs: Any) -> Query {
    return Query(op: .greaterThan, key: lhs, value: rhs)
}
public func <(lhs: String, rhs: Any) -> Query {
    return Query(op: .lowerThan, key: lhs, value: rhs)
}
public func >=(lhs: String, rhs: Any) -> Query {
    return Query(op: .greaterThanOrEqual, key: lhs, value: rhs)
}
public func <=(lhs: String, rhs: Any) -> Query {
    return Query(op: .lowerThanOrEqual, key: lhs, value: rhs)
}
