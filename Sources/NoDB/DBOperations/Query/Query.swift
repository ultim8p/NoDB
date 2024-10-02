//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

public struct Query {
    
    var op: QueryOperator?
    var key: String?
    var value: Any?
    
    public init(op: QueryOperator? = nil, key: String? = nil, value: Any? = nil) {
        self.op = op
        self.key = key
        self.value = value
    }
}
