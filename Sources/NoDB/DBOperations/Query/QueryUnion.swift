//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

public protocol QueryUnion {
    var queries: [Query]? { get set }
}
public struct QueryOr: QueryUnion {
    public var queries: [Query]?
}
public struct QueryAnd: QueryUnion {
    public var queries: [Query]?
}
