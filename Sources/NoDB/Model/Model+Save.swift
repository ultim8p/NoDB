//
//  Model+Save.swift
//  RIDB
//
//  Created by Guerson on 2020-06-21.
//  Copyright © 2020 rise. All rights reserved.
//

import Foundation
import BinarySearch

extension DBModel {
    static var dbName: String {
        return String(describing: self).lowercased()
    }
    
    //Just call this method when ypu know FOR SURE that new indexes should be created
    func insertIndexes(withDBName dbName: String, idKey: String, indexesManager: IndexesManager) {
        let indexes = type(of: self).noDBIndexes ?? []
        indexes.insertIndexes(for: self, withDBName: dbName, idKey: idKey, indexesManager: indexesManager)
    }
    
//    func upsertIndexes(withDBName dbName: String) {
//        let indexes = type(of: self).noDBIndexes
//        indexes?.upsertIndexes(for: self, withDBName: dbName)
//    }
    
    func replaceIndexes(with newObj: Self, withDBName dbName: String, idKey: String, indexesManager: IndexesManager) {
        let indexes = type(of: self).noDBIndexes ?? []
        indexes.replaceIndexes(for: self, with: newObj, withDBName: dbName, idKey: idKey, indexesManager: indexesManager)
    }
    
    func updateIndexes(with newObj: Self, withDBName dbName: String, idKey: String, indexesManager: IndexesManager) {
        let indexes = type(of: self).noDBIndexes ?? []
        indexes.updateIndexes(for: self, newObj: newObj, withDBName: dbName, idKey: idKey, indexesManager: indexesManager)
    }
    
    func deleteIndexes(withDBName dbName: String, idKey: String, indexesManager: IndexesManager) {
        let indexes = type(of: self).noDBIndexes ?? []
        indexes.deleteIndexes(for: self, withDBName: dbName, idKey: idKey, indexesManager: indexesManager)
    }

    func updateIndexes(newNoDBIndexes: [String], withDBName dbName: String, indexesManager: IndexesManager){
        let indexes = type(of: self).noDBIndexes ?? []
        indexes.updateIndex(for: self, newNoDBIndexes: newNoDBIndexes, withDBName: dbName, indexesManager: indexesManager)
    }
    
    func saveIndexesList(withDBName dbName: String, indexesManager: IndexesManager) {
        let indexes = type(of: self).noDBIndexes ?? []
        indexes.saveIndexList(for: self, withDBName: dbName, indexesManager: indexesManager)
    }
}

extension Array where Element: DBModel {
    
    /// Find an object in the array with a specific id.
    /// - Parameters:
    ///     - withId: Id value of the object to find.
    ///     - dbName: Name of the database to search the object for.
    /// - Returns: Object found for the specified id.
    func object(withId objId: Any, dbName: String, indexesManager: IndexesManager) -> Element? {
        return self.object(with: NoDBConstant.id.rawValue,
                           value: objId,
                           dbName: dbName,
                           indexesManager: indexesManager)
    }
    
    /// Find an object and it's position index in the array with a specific id.
    /// - Parameters:
    ///     - withId: Id value of the object to find.
    ///     - dbName: Name of the database to search the object for.
    /// - Returns: Object found for the specified id.
    /// - Returns: Index of the element found in this array.
    func objectAndIndex(withId objId: Any, dbName: String, indexesManager: IndexesManager) -> (obj: Element?, index: Int?) {
        return self.objectAndIndex(with: NoDBConstant.id.rawValue,
                                   value: objId,
                                   dbName: dbName,
                                   indexesManager: indexesManager)
    }
    
    /// Find an object with a specific key value pair in this array.
    /// - Parameters:
    ///     - key: Name of the key to search the value for.
    ///     - value: Value of the key.
    ///     - dbName: Name of the database to search the object for.
    /// - Returns: Object found for the specified key value pair.
    func object(with key: String, value: Any, dbName: String, indexesManager: IndexesManager) -> Element? {
        guard let indexes = self.indexes(for: key, dbName: dbName, indexesManager: indexesManager),
            let indexValue = indexes.indexValue(for: key, value: value),
            self.rangeContains(index: indexValue) else { return nil }
        return self[indexValue]
    }
    
    /// Find an object and it's position index with a specific key value pair in this array.
    /// - Parameters:
    ///     - key: Name of the key to search the value for.
    ///     - value: Value of the key.
    ///     - dbName: Name of the database to search the object for.
    /// - Returns: Object found for the specified key value pair.
    /// - Returns: Index of the object found in this array.
    func objectAndIndex(with key: String, value: Any, dbName: String, indexesManager: IndexesManager) -> (obj: Element?, index: Int?) {
        guard let indexes = self.indexes(for: key, dbName: dbName, indexesManager: indexesManager),
            let indexValue = indexes.indexValue(for: key, value: value),
            self.rangeContains(index: indexValue) else { return (nil, nil) }
        return (self[indexValue], indexValue)
    }
    
    /// Returns the array of indexes for a specified key and database name.
    /// - Parameters:
    ///     - key: Name of the key for the indexes.
    ///     - dbName: Name of the database of the indexes.
    /// - Returns: Array of indexes for the specified key and database name.
    func indexes(for key: String, dbName: String, indexesManager: IndexesManager) -> [[String: Any]]? {
        let indexDBName = dbName + ":" + key
        guard let indexes = indexesManager.get(withType: .indexes, indexDBName: indexDBName) else { return nil }
        return indexes
    }
    
    
    /// Finds the index in which a new object should be inserted in the array.
    /// If the deletions database contains at least one object, the new object will occupy the postion of the first item in deleted indexes database.
    /// - Parameters:
    ///     - dbName: Name of the database of the mode.
    func getIndexForInsertion(withDBName dbName: String, indexesManager: IndexesManager) -> (index: Int, shouldReplace: Bool) {
        let indexDBName = IndexesNameType.deleted.getFullName(with: dbName)
        guard let deletions = indexesManager.get(withType: .deletions,
                                                        indexDBName: indexDBName),
            let deletedIndexDict = deletions.first,
            let index = deletedIndexDict[NoDBConstant.index.rawValue] as? Int else { return (self.count, false) }
        indexesManager.delete(indexType: .deletions,
                                     indexDBName: indexDBName,
                                     sortKey: NoDBConstant.id.rawValue,
                                     indexDict: deletedIndexDict)
        return (index, true)
    }
    
    
    // TODO: Refactor core search methods.
    func searchRange(with key: String, lowerValue: Any, lowerOpt: LowerOperator, upperValue: Any, upperOpt: UpperOperator, limit: Int?, bound: Bound, withDBName dbName: String, indexesManager: IndexesManager) -> [Element]? {
        let indexDBName = dbName + ":" + key
        guard let indexes = indexesManager.get(withType: .indexes, indexDBName: indexDBName) else { return nil }
        guard let indexesResults = indexes.searchRange(with: key, lowerValue: lowerValue, lowerOpt: lowerOpt, upperValue: upperValue, upperOpt: upperOpt, limit: limit, bound: bound) else { return nil}
        return models(fromIndexes: indexesResults)
    }

    func searchRange(with key: String, value: Any, operatr: LowerOperator, withDBName dbName: String, indexesManager: IndexesManager) -> [Element]? {
        let indexDBName = dbName + ":" + key
        guard let indexes = indexesManager.get(withType: .indexes, indexDBName: indexDBName) else { return nil }
        guard let indexesResults = indexes.searchRange(with: key, value: value, withOp: operatr) else { return nil}
        return models(fromIndexes: indexesResults)
    }

    func searchRange(with key: String, value: Any, operatr: UpperOperator, withDBName dbName: String, indexesManager: IndexesManager) -> [Element]? {
        let indexDBName = dbName + ":" + key
        guard let indexes = indexesManager.get(withType: .indexes, indexDBName: indexDBName) else { return nil }
        guard let indexesResults = indexes.searchRange(with: key, value: value, withOp: operatr) else { return nil}
        return models(fromIndexes: indexesResults)
    }

    func searchRange(with key: String, value: Any, operatr: ExclusiveOperator, limit: Int?, skip: Int? = nil, withDBName dbName: String, indexesManager: IndexesManager) -> [Element]? {
        let indexDBName = dbName + ":" + key
        guard let indexes = indexesManager.get(withType: .indexes, indexDBName: indexDBName) else { return nil }
        guard let indexesResults = indexes.searchRange(with: key, value: value, withOp: operatr, limit: limit, skip: skip) else { return nil }
        return models(fromIndexes: indexesResults)
    }
    
    // TODO: Replace by find() method
    func getAllValid(withDBName dbName: String, indexesManager: IndexesManager) -> [Element]? {
        let indexDBName = dbName + ":" + NoDBConstant.id.rawValue
        guard let indexesResults = indexesManager.get(withType: .indexes, indexDBName: indexDBName) else  { return nil }
        return models(fromIndexes: indexesResults)
    }
    
}
