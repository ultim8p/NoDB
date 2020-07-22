//
//  IndexesManager.swift
//  RIDB
//
//  Created by Ita on 6/21/20.
//  Copyright © 2020 rise. All rights reserved.
//

import Foundation

class IndexesManager {
    static var shared = IndexesManager()

    private var indexesNamesSaved: [String: [[String: Any]]] = [:]
    var indexes: [String: [[String: Any]]] = [:]
    var deletions: [String: [[String: Any]]] = [:]
    
    
    func insert(in type: IndexesType = .indexes, indexDBName: String, indexDict: [String: Any], key: String) {
        switch type {
        case .indexes:
            if self.indexes[indexDBName] == nil {
                self.indexes[indexDBName] = []
            }
            self.indexes[indexDBName]?.insert(indexDict, key: key)
        case .deletions:
            if self.deletions[indexDBName] == nil {
                self.deletions[indexDBName] = []
            }
            self.deletions[indexDBName]?.insert(indexDict, key: key)
        }
    }
    
    func upsert(indexDBName: String, indexDict: [String: Any], key: String) {
        if self.indexes[indexDBName] == nil {
            self.indexes[indexDBName] = []
        }
        self.indexes[indexDBName]?.upsert(indexDict, key: key)
    }
    
    func delete(in type: IndexesType = .indexes, indexDBName: String, indexDict: [String: Any], key: String) {
        switch type {
        case .indexes:
            self.indexes[indexDBName]?.delete(indexDict, key: key)
        case .deletions:
            self.deletions[indexDBName]?.delete(indexDict, key: key)
        }
    }

    func loadDB(withName dbName: String, noDBIndexes: [String]?) -> [Int]? {
        let typeIndex = type(of: [[String: Any]]())
        let savedIndexsDBName = IndexesTypeName.savedIndexes.getFullName(with: dbName)
//        indexesNamesSaved[savedIndexsDBName] = typeIndex.loadDB(savedIndexsDBName)
        var newKeysIndexs: [Int] = []
        for (index, indexName) in (noDBIndexes ?? []).enumerated() {
            let indexKey = dbName + ":" + indexName
            if let _ = indexesNamesSaved[savedIndexsDBName]?.binarySearch(key: NoDBConstant.indexSaved.rawValue, value: indexName).currentIndex {
                indexes[indexKey] = typeIndex.loadDB(indexKey)
            } else {
                insertToSavedIndexs(with: dbName, indexName: indexName)
                newKeysIndexs.append(index)
            }
        }
        let deletedDBName = IndexesTypeName.deleted.getFullName(with: dbName)
        deletions[deletedDBName] = typeIndex.loadDB(deletedDBName)
        return !newKeysIndexs.isEmpty ? newKeysIndexs : nil
    }
    
    func saveDB(with dbName: String, noDBIndexes: [String]?) {
        updateAndSavedIndexes(with: dbName, noDBIndexes: noDBIndexes)
        let savedIndexsDBName = IndexesTypeName.savedIndexes.getFullName(with: dbName)
        let deletedIndexsDBName = IndexesTypeName.deleted.getFullName(with: dbName)
        indexesNamesSaved[savedIndexsDBName]?.saveDB(savedIndexsDBName)
        deletions[deletedIndexsDBName]?.saveDB(deletedIndexsDBName)
    }
    
    func deleteDB(with dbName: String, noDBIndexes: [String]?) {
        let savedIndexsDBName = IndexesTypeName.savedIndexes.getFullName(with: dbName)
        _ = indexesNamesSaved[savedIndexsDBName]?.deleteDB(savedIndexsDBName)
        for key in noDBIndexes ?? [] {
            let keyName = dbName + ":" + key
            indexes[keyName]?.deleteDB(keyName)
        }
        let deletedIndexsDBName = IndexesTypeName.deleted.getFullName(with: dbName)
        deletions[deletedIndexsDBName]?.deleteDB(deletedIndexsDBName)
    }

    func saveDB() {
        for indexes in indexes {
            indexes.value.saveDB(indexes.key)
        }
        for deletions in deletions {
            deletions.value.saveDB(deletions.key)
        }
        for keys in indexesNamesSaved {
            keys.value.saveDB(keys.key)
        }
    }
    
    func insertToSavedIndexs(with dbName: String, indexName: String) {
//        if indexesNamesSaved[dbName] == nil {
//            indexesNamesSaved[dbName] = []
//        }
//        let key = NoDBConstant.indexSaved.rawValue
//        let newDict: [String: Any] = [key: indexName]
//        indexesNamesSaved[dbName]?.upsert(newDict, key: key)
    }

    private func updateAndSavedIndexes(with dbName: String, noDBIndexes: [String]?){
        let savedIndexsDBName = IndexesTypeName.savedIndexes.getFullName(with: dbName)
        for (index, indexObj) in (indexesNamesSaved[savedIndexsDBName] ?? []).enumerated() {
            guard let indexValue = indexObj[NoDBConstant.indexSaved.rawValue] as? String else {
                continue
            }
            let keyName = dbName + ":" + indexValue
            if (noDBIndexes?.contains(indexValue) ?? false) {
                indexes[keyName]?.saveDB(keyName)
            } else {
                indexesNamesSaved[savedIndexsDBName]?.remove(at: index)
                indexes[keyName] = nil
            }
        }
    }

}
