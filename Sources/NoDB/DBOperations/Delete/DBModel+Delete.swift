//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation


extension Array where Element: DBModel {
    /// Deletes an object from the database with a specified key value pair.
    /// - Parameters:
    ///     - key: Name of the key to search the value for.
    ///     - value: Value of the key to search for.
    ///     - idKey: Name of the property which contains the object's id.
//    mutating func delete(key: String, value: Any, dbName: String, idKey: String) {
//        let objectQ = objectAndIndex(with: key, value: value, dbName: dbName)
//        guard let oldObj = objectQ.obj,
//            objectQ.index != nil else { return }
//        oldObj.deleteIndexes(withDBName: dbName, idKey: idKey)
//    }
    
    /// Deletes all objects that match a specified Query.
    func delete(_ query: Query, dbName: String, idKey: String) -> [Element]? {
        guard let deletingObjs = find(query, dbName: dbName, idKey: idKey) else { return nil }
        for obj in deletingObjs {
            if let objId = obj.modelStringValue(for: idKey) {
                delete(id: objId, withDBName: dbName, idKey: idKey)
            }
        }
        return deletingObjs
    }
    
    /// Deletes an object with a specified id.
    func delete(id: String?, withDBName dbName: String, idKey: String) {
        guard let id = id else {
            return
        }
        let binaryObj = objectAndIndex(withId: id, dbName: dbName)
        guard let oldObj = binaryObj.obj, let _ = binaryObj.index else { return }
        oldObj.deleteIndexes(withDBName: dbName, idKey: idKey)
    }
}
