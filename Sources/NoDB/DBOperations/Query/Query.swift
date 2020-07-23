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
    
    static func all() -> Query {
        return Query()
    }
}
