//
//  File.swift
//  
//
//  Created by Guerson on 2020-07-21.
//

import Foundation

enum IndexesNameType {
    case deleted
    case savedIndexs
    
    func getFullName(with dbName: String) -> String {
        switch self {
        case .deleted:
            return dbName + ":" + "deleted"
        case .savedIndexs:
            return "indexes" + ":" + dbName
        }
    }
}
