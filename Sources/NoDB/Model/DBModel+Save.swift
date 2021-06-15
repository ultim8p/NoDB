//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

extension Array where Element: DBModel {
    
    mutating func save(_ objs: [Element?],
                       withDBName dbName: String,
                       idKey: String,
                       indexesManager: IndexesManager,
                       replace: Bool = false) -> [Element]? {
        var savedIds: [[String: Any]] = []
        var elementsSaved: [Element] = []
        for obj in objs {
            guard let saveResult = self.save(obj, withDBName: dbName, idKey: idKey, indexesManager: indexesManager, replace: replace) else { continue }
            let idDict: [String: Any] = [idKey: saveResult.noDBId]
            guard let upsertedInIndex = savedIds.upsert(idDict, key: idKey) else { continue }
            if let upserCurrentIndex = upsertedInIndex.currentIndex, upserCurrentIndex < elementsSaved.count {
                elementsSaved[upserCurrentIndex] = saveResult.element
            } else if let insertedIndex = upsertedInIndex.insertingIndex, elementsSaved.canInsert(at: insertedIndex) {
                elementsSaved.insert(saveResult.element, at: insertedIndex)
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
    private mutating func save(_ obj: Element?,
                               withDBName dbName: String,
                               idKey: String,
                               indexesManager: IndexesManager,
                               replace: Bool) -> SaveModel<Element>? {
        guard var obj = obj,
            let id = obj.modelId(idKey: idKey) else {
            return nil
        }
        let binaryObj = objectAndIndex(withId: id, dbName: dbName, indexesManager: indexesManager)
        if var oldObj = binaryObj.obj, let objIndex = binaryObj.index {
            if replace {
                obj.noDBIndex = objIndex
                oldObj.replaceIndexes(with: obj, withDBName: dbName, idKey: idKey, indexesManager: indexesManager)
                self[objIndex] = obj
                return SaveModel(element: obj, noDBId: id)
            } else {
                let oldObjCopy = oldObj
                if let changes = oldObj.merge(Element.self, with: obj, idKey: idKey) {
                    oldObjCopy.updateIndexes(with: changes, withDBName: dbName, idKey: idKey, indexesManager: indexesManager)
                }
                self[objIndex] = oldObj
                return SaveModel(element: oldObj, noDBId: id)
            }
        } else {
            if self.isEmpty {
                obj.saveIndexesList(withDBName: dbName, indexesManager: indexesManager)
            }
            let indexInfo = self.getIndexForInsertion(withDBName: dbName, indexesManager: indexesManager)
            let index = indexInfo.index
            obj.noDBIndex = index
            if indexInfo.shouldReplace, self.rangeContains(index: index) {
                self[index] = obj
            } else if self.canInsert(at: index) {
                self.insert(obj, at: index)
            }
            obj.insertIndexes(withDBName: dbName, idKey: idKey, indexesManager: indexesManager)
            return SaveModel(element: obj, noDBId: id)
        }
    }

}
