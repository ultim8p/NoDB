//
//  Encodable+Save.swift
//  RIDB
//
//  Created by Guerson on 2020-05-23.
//  Copyright © 2020 rise. All rights reserved.
//

import Foundation
import CodableUtils

extension Encodable {
    
    static var dbName: String {
        return self.className
    }
    
    // Add support for single element DB
//    func saveDB() {
//        do {
//            let objData = try JSONEncoder().encode(self)
//            _ = RIArchiever.save(fileName: Self.dbName, object: objData)
//        } catch {
//            print("DBEncodErr: \(String(describing: Self.dbName)) \(error)")
//        }
//    }
    
}

extension Array where Element: Encodable {
    
    func saveDB() {
        let fileName = Element.dbName
        self.saveDB(fileName)
    }
    
    func saveDB(_ name: String) {
        do {
            let objData = try JSONEncoder().encode(self)
            _ = RIArchiever.save(fileName: name, object: objData)
        } catch {
            print("DBEncodErr: \(String(describing: name)) \(error)")
        }
    }
}


extension Array where Element == [String: Any] {
    
//    func saveDB() {
//        let fileName = Element.dbName
//        self.saveDB(fileName)
//    }
    
    func saveDB(_ name: String) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            _ = RIArchiever.save(fileName: name, object: jsonData)
        } catch {
            print("DBEncodErr: \(String(describing: name)) \(error)")
        }
    }
}
