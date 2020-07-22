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
//    private let queue = DispatchQueue(customType: .indexesManager)

    private var indexesNamesSaved: [String: [[String: Any]]] = [:]
    var indexes: [String: [[String: Any]]] = [:]
    var deletions: [String: [[String: Any]]] = [:]
    
    func insert(in dict: IndexesType = .indexes, indexDBName: String, indexDict: [String: Any], key: String) {
        switch dict {
        case .indexes:
            if indexes[indexDBName] == nil {
                indexes[indexDBName] = []
            }
            self.indexes[indexDBName]?.insert(indexDict, key: key)
        case .deletions:
            if deletions[indexDBName] == nil {
                deletions[indexDBName] = []
            }
            deletions[indexDBName]?.insert(indexDict, key: key)
        }
    }
    
    func upsert(indexDBName: String, indexDict: [String: Any], key: String) {
        if self.indexes[indexDBName] == nil {
            self.indexes[indexDBName] = []
        }
        self.indexes[indexDBName]?.upsert(indexDict, key: key)
    }
    
    func delete(in dict: IndexesType = .indexes, indexDBName: String, indexDict: [String: Any], key: String) {
        switch dict {
        case .indexes:
            indexes[indexDBName]?.delete(indexDict, key: key)
        case .deletions:
            deletions[indexDBName]?.delete(indexDict, key: key)
        }
    }

    func loadDB(withName dbName: String, noDBIndexes: [String]?) -> [Int]? {
        let typeIndex = type(of: [[String: Any]]())
        let savedIndexsDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
        indexesNamesSaved[savedIndexsDBName] = typeIndex.loadDB(savedIndexsDBName)
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
        let deletedDBName = IndexesNameType.deleted.getFullName(with: dbName)
        deletions[deletedDBName] = typeIndex.loadDB(deletedDBName)
        return !newKeysIndexs.isEmpty ? newKeysIndexs : nil
    }
    
    func saveDB(with dbName: String, noDBIndexes: [String]?) {
        updateAndSavedIndexes(with: dbName, noDBIndexes: noDBIndexes)
        let savedIndexsDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
        let deletedIndexsDBName = IndexesNameType.deleted.getFullName(with: dbName)
        indexesNamesSaved[savedIndexsDBName]?.saveDB(savedIndexsDBName)
        deletions[deletedIndexsDBName]?.saveDB(deletedIndexsDBName)
    }
    
    func deleteDB(with dbName: String, noDBIndexes: [String]?) {
        let savedIndexsDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
            _ = indexesNamesSaved[savedIndexsDBName]?.deleteDB(savedIndexsDBName)
        for key in noDBIndexes ?? [] {
            let keyName = dbName + ":" + key
            indexes[keyName]?.deleteDB(keyName)
        }
        let deletedIndexsDBName = IndexesNameType.deleted.getFullName(with: dbName)
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
        let savedIndexsDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
            if indexesNamesSaved[savedIndexsDBName] == nil {
                indexesNamesSaved[savedIndexsDBName] = []
        }
        let key = NoDBConstant.indexSaved.rawValue
        let newDict: [String: Any] = [key: indexName]
            indexesNamesSaved[savedIndexsDBName]?.upsert(newDict, key: key)
    }

    private func updateAndSavedIndexes(with dbName: String, noDBIndexes: [String]?){
        let savedIndexsDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
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
