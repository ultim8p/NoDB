//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

public struct Sort {
    public var key: String
    public var order: SortOrder
    
    public init(key: String, order: SortOrder) {
        self.key = key
        self.order = order
    }
}
