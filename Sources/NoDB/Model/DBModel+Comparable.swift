//
//  File.swift
//  
//
//  Created by Ita on 7/2/20.
//

import Foundation

public extension DBModel {
    static func <(lhs: Self, rhs: Self) -> Bool {
        return (lhs._id ?? "") < (rhs._id ?? "")
    }
}
