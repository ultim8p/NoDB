//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

extension Array where Element: DBModel {
    
    mutating func save(_ objs: [Element?], withDBName dbName: String, idKey: String) -> [Element]? {
        var savedIdsDict: [[String:Any]] = []
        var elementsSaved: [Element] = []
        for obj in objs {
            guard let saveResult = self.save(obj, withDBName: dbName, idKey: idKey) else { continue }
            let idDict: [String: Any] = [idKey: saveResult.noDBId]
            guard let upsertedInIndex = savedIdsDict.upsert(idDict, key: idKey) else { continue }
            if upsertedInIndex < elementsSaved.count {
                elementsSaved[upsertedInIndex] = saveResult.element
            } else {
                elementsSaved.append(saveResult.element)
            }
        }
        return elementsSaved
    }

    /// Saves an object in an array of DBModel objects.
    /// Objects will be saved uniquely by using the id property.
    /// If an objects with the same id already existed, the new object properties will be merged into the existing object in this array.
    /// Indexing will be handled by using the defined indexable keys in the model's noDBIndexes property.
    /// Indexing will be used to perform high-performance operations in the database like query, delete and update.
    /// - Note: Objects must have an id in order to be saved. Objects with no id will be ignored. You can specify the name of the id property in the "idKey" parameter.
    private mutating func save(_ obj: Element?, withDBName dbName: String, idKey: String) -> SaveModel<Element>? {
        guard var obj = obj,
            let id = obj.modelStringValue(for: idKey),
            !id.isEmpty else {
            return nil
        }
        let binaryObj = objectAndIndex(withId: id, dbName: dbName)
        if var oldObj = binaryObj.obj, let objIndex = binaryObj.index {
            let oldObjCopy = oldObj
            if let changes = oldObj.merge(Element.self, with: obj, idKey: idKey) {
                oldObjCopy.updateIndexes(with: changes, withDBName: dbName, idKey: idKey)
            }
            self[objIndex] = oldObj
            return SaveModel(element: oldObj, noDBId: id)
        } else {
            if self.isEmpty {
                obj.saveIndexesList(withDBName: dbName)
            }
            let index = self.getIndexForInsertion(withDBName: dbName)
            obj.noDBIndex = index
            self.insert(obj, at: index)
            obj.insertIndexes(withDBName: dbName, idKey: idKey)
            return SaveModel(element: obj, noDBId: id)
        }
    }

}
