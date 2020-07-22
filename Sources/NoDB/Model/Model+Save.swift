//
//  Model+Save.swift
//  RIDB
//
//  Created by Guerson on 2020-06-21.
//  Copyright © 2020 rise. All rights reserved.
//

import Foundation
import BinarySearch

extension Array where Element: DBModel {

    mutating func save(_ obj: inout Element?, withDBName dbName: String) {
        guard var copyObj = obj, let id = copyObj._id, !id.isEmpty else {
            obj = nil
            return
        }
        let binaryObj = objectAndIndex(withId: id, withDBName: dbName)
        if var oldObj = binaryObj.obj, let objIndex = binaryObj.index {
            let oldObjCopy = oldObj
            if let changes = oldObj.merge(Element.self, with: copyObj) {
                oldObjCopy.updateIndexes(with: changes, withDBName: dbName)
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
            copyObj.insertIndexes(withDBName: dbName)
            obj = copyObj
        }
    }

}

extension DBModel {
    static var dbName: String {
        return String(describing: self).lowercased()
    }
    
    //Just call this method when ypu know FOR SURE that new indexes should be created
    func insertIndexes(withDBName dbName: String) {
        let indexes = type(of: self).noDBIndexes
        indexes?.insertIndexes(for: self, withDBName: dbName)
    }
    
    func upsertIndexes(withDBName dbName: String) {
        let indexes = type(of: self).noDBIndexes
        indexes?.upsertIndexes(for: self, withDBName: dbName)
    }
    
    func updateIndexes(with newObj: Self, withDBName dbName: String) {
        let indexes = type(of: self).noDBIndexes
        indexes?.updateIndexes(for: self, newObj: newObj, withDBName: dbName)
    }
    
    func deleteIndexes(withDBName dbName: String) {
        let indexes = type(of: self).noDBIndexes
        indexes?.deleteIndexes(for: self, withDBName: dbName)
    }

    func updateIndexes(forIndexsAt indexs: [Int], withDBName dbName: String){
        let indexes = type(of: self).noDBIndexes
        indexes?.updateIndex(for: self, forIndexsAt: indexs, withDBName: dbName)
    }
    
    func saveIndexesList(withDBName dbName: String) {
        let indexes = type(of: self).noDBIndexes
        indexes?.saveIndexList(for: self, withDBName: dbName)
    }
}

extension Array where Element: DBModel {
    func object(withId objId: String, withDBName dbName: String) -> Element? {
        return self.object(with: "_id", value: objId, withDBName: dbName)
    }
    
    func objectAndIndex(withId objId: String, withDBName dbName: String) -> (obj: Element?, index: Int?) {
        let key = "_id"
        return self.objectAndIndex(with: key, value: objId, withDBName: dbName)
    }
    
    func object(with key: String, value: Any, withDBName dbName: String) -> Element? {
        guard let indexes = self.indexes(for: key, withDBName: dbName),
            let indexValue = indexes.indexValue(for: key, value: value) else { return nil }
        return self[indexValue]
    }
    
    func objectAndIndex(with key: String, value: Any, withDBName dbName: String) -> (obj: Element?, index: Int?) {
        guard let indexes = self.indexes(for: key, withDBName: dbName),
            let indexValue = indexes.indexValue(for: key, value: value) else { return (nil, nil) }
        return (self[indexValue], indexValue)
    }
    
    func indexes(for key: String, withDBName dbName: String) -> [[String: Any]]? {
        let keyName = dbName + ":" + key
        guard let indexes = IndexesManager.shared.indexes[keyName] else { return nil }
        return indexes
    }
    
    func getIndexForInsertion(withDBName dbName: String) -> Int {
        let keyName = IndexesTypeName.deleted.getFullName(with: dbName)
        guard let deletions = IndexesManager.shared.deletions[keyName], let first = deletions.first, let index = first[NoDBConstant.index.rawValue] as? Int else { return self.count }
        IndexesManager.shared.delete(in: .deletions, indexDBName: keyName, indexDict: first, key: "_id")
        return index
    }
    
    func countValid(withDBName dbName: String) -> Int {
        guard let deletions = IndexesManager.shared.deletions[IndexesTypeName.deleted.getFullName(with: dbName)] else { return self.count }
        return self.count - deletions.count
    }
    
    func searchRange(with key: String, lowerValue: Any, lowerOpt: LowerOperator, upperValue: Any, upperOpt: UpperOperator, limit: Int?, bound: Bound) -> [Element]? {
        let indexDBName = Element.dbName + ":" + key
        guard let indexes = IndexesManager.shared.indexes[indexDBName] else { return nil }
        guard let indexsResults = indexes.searchRange(with: key, lowerValue: lowerValue, lowerOpt: lowerOpt, upperValue: upperValue, upperOpt: upperOpt, limit: limit, bound: bound) else { return nil}
        return getObjects(for: indexsResults)
    }
    
    func searchRange(with key: String, value: Any, withOp operatr: ExclusiveOperator, limit: Int?, skip: Int? = nil) -> [Element]? {
        let indexDBName = Element.dbName + ":" + key
        guard let indexes = IndexesManager.shared.indexes[indexDBName] else { return nil }
        guard let indexsResults = indexes.searchRange(with: key, value: value, withOp: operatr, limit: limit, skip: skip) else { return nil }
        return getObjects(for: indexsResults)
    }
    
    func getAllValid() -> [Element]? {
        let indexDBName = Element.dbName + ":" + "_id"
        guard let indexesRsults = IndexesManager.shared.indexes[indexDBName] else { return nil }
        return getObjects(for: indexesRsults)
    }
    
    func getObjects(for indexArray: [[String: Any]]) -> [Element] {
        var results: [Element] = []
        for result in indexArray {
            guard let indexValue = result.indexValue() else { continue }
            results.append(self[indexValue])
        }
        return results
    }
}
