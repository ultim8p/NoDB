//
//  Decodable+Load.swift
//  RIDB
//
//  Created by Guerson on 2020-05-23.
//  Copyright © 2020 rise. All rights reserved.
//

import Foundation
import CodableUtils

extension Decodable {
    
    static var dbName: String {
        return self.className
    }
    
    //TODO: Add support for single element DB
//    static func loadDB() -> Self? {
//        guard let data = RIArchiever.load(fileName: Self.dbName) as? Data else { return nil }
//        do {
//            return try JSONDecoder().decode(Self.self, from: data)
//        } catch {
//            print("DBDecodErr: \(String(describing: Self.dbName)) \(error)")
//        }
//        return nil
//    }
    
}

extension Array where Element: Decodable {
    
    static func loadDB() -> Self? {
        let fileName = Element.dbName
        return self.loadDB(fileName)
    }
    
    static func loadDB(_ name: String) -> Self? {
        guard let data = RIArchiever.load(fileName: name) as? Data else { return nil }
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            print("DBDecodErr: \(String(describing: name)) \(error)")
        }
        return nil
    }
    
}

extension Array where Element == [String: Any] {
    
    static func loadDB(_ name: String) -> Self? {
        guard let data = RIArchiever.load(fileName: name) as? Data else { return nil }
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
        } catch {
            print("DBDecodErr: \(String(describing: name)) \(error)")
        }
        return nil
    }
    
}
