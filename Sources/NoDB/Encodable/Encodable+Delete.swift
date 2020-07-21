//
//  File.swift
//  
//
//  Created by Ita on 7/2/20.
//

import Foundation

extension Array where Element: Encodable {
    
    mutating func deleteDB() {
        let fileName = Element.dbName
        _ = self.deleteDB(fileName)
    }
    
    mutating func deleteDB(_ name: String) -> Bool {
        if RIArchiever.delete(fileName: name) == nil {
            self = []
            return true
        }
        return false
    }
}

extension Array where Element == [String: Any] {
    
    mutating func deleteDB(_ name: String) {
        if RIArchiever.delete(fileName: name) == nil {
            self = []
        }
    }
}
