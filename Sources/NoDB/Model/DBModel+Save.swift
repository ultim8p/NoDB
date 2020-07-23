//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

extension Array where Element: DBModel {

    /// Saves an object in an array of DBModel objects.
    /// Objects will be saved uniquely by using the id property.
    /// If an objects with the same id already existed, the new object properties will be merged into the existing object in this array.
    /// Indexing will be handled by using the defined indexable keys in the model's noDBIndexes property.
    /// Indexing will be used to perform high-performance operations in the database like query, delete and update.
    /// - Note: Objects must have an id in order to be saved. Objects with no id will be ignored. You can specify the name of the id property in the "idKey" parameter.
    mutating func save(_ obj: inout Element?, withDBName dbName: String, idKey: String) {
        guard var copyObj = obj,
            let id = copyObj.modelStringValue(for: idKey),
            !id.isEmpty else {
            obj = nil
            return
        }
        let binaryObj = objectAndIndex(withId: id, dbName: dbName)
        if var oldObj = binaryObj.obj, let objIndex = binaryObj.index {
            let oldObjCopy = oldObj
            if let changes = oldObj.merge(Element.self, with: copyObj, idKey: idKey) {
                oldObjCopy.updateIndexes(with: changes, withDBName: dbName, idKey: idKey)
            }
            obj = oldObj
            self[objIndex] = oldObj
        } else {
            if self.isEmpty {
                copyObj.saveIndexesList(withDBName: dbName)
            }
            let index = self.getIndexForInsertion(withDBName: dbName)
            copyObj.noDBIndex = index
            self.insert(copyObj, at: index)
            copyObj.insertIndexes(withDBName: dbName, idKey: idKey)
            obj = copyObj
        }
    }

}
