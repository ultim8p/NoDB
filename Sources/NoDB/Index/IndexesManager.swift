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

    private var indexesRegister: [String: [[String: Any]]] = [:]
    var indexes: [String: [[String: Any]]] = [:]
    var deletions: [String: [[String: Any]]] = [:]
    
    
    func insert(in dict: table = .indexes, indexDBName: String, indexDict: [String: Any], key: String) {
        switch dict {
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
    
    func delete(in dict: table = .indexes, indexDBName: String, indexDict: [String: Any], key: String) {
        switch dict {
        case .indexes:
            self.indexes[indexDBName]?.delete(indexDict, key: key)
        case .deletions:
            self.deletions[indexDBName]?.delete(indexDict, key: key)
        }
    }

    func loadDB<T: DBModel>(for model: T.Type) -> [Int]? {
        let dbName = model.dbName
        let typeIndex = type(of: [[String: Any]]())
        let savedIndexsDBName = model.savedIndexsDBName
        indexesRegister[savedIndexsDBName] = typeIndex.loadDB(savedIndexsDBName)
        var newKeysIndexs: [Int] = []
        for (index, indexName) in (model.noDBIndexes ?? []).enumerated() {
            let indexKey = dbName + ":" + indexName
            if let _ = indexesRegister[savedIndexsDBName]?.binarySearch(key: NoDBConstant.indexSaved.rawValue, value: indexName).currentIndex {
                indexes[indexKey] = typeIndex.loadDB(indexKey)
            } else {
                insertToSavedIndexs(withName: savedIndexsDBName, indexName: indexName)
                newKeysIndexs.append(index)
            }
        }
        let deletedDBName = model.deletedIndexdbName
        deletions[deletedDBName] = typeIndex.loadDB(deletedDBName)
        return !newKeysIndexs.isEmpty ? newKeysIndexs : nil
    }
    
    func saveDB<T: DBModel>(for model: T.Type) {
        updateAndSavedIndexes(for: model)
        indexesRegister[model.savedIndexsDBName]?.saveDB(model.savedIndexsDBName)
        deletions[model.deletedIndexdbName]?.saveDB(model.deletedIndexdbName)
    }
    
    func deleteDB<T: DBModel>(for model: T.Type) {
        let dbName = model.dbName
        let savedIndexsDBName = model.savedIndexsDBName
        _ = indexesRegister[savedIndexsDBName]?.deleteDB(savedIndexsDBName)
        for key in model.noDBIndexes ?? [] {
            let keyName = dbName + ":" + key
            indexes[keyName]?.deleteDB(keyName)
        }
        deletions[model.deletedIndexdbName]?.deleteDB(model.deletedIndexdbName)
    }

    func saveDB() {
        for indexes in indexes {
            indexes.value.saveDB(indexes.key)
        }
        for deletions in deletions {
            deletions.value.saveDB(deletions.key)
        }
        for keys in indexesRegister {
            keys.value.saveDB(keys.key)
        }
    }
    
    func insertToSavedIndexs(withName name: String, indexName: String) {
        if indexesRegister[name] == nil {
            indexesRegister[name] = []
        }
        let key = NoDBConstant.indexSaved.rawValue
        let newDict: [String: Any] = [key: indexName]
        indexesRegister[name]?.upsert(newDict, key: key)
    }

    private func updateAndSavedIndexes<T: DBModel>(for model: T.Type){
        let savedIndexsDBName = model.savedIndexsDBName
        let dbName = model.dbName
        for (index, indexObj) in (indexesRegister[savedIndexsDBName] ?? []).enumerated() {
            guard let indexValue = indexObj[NoDBConstant.indexSaved.rawValue] as? String else {
                continue
            }
            let keyName = dbName + ":" + indexValue
            if (model.noDBIndexes?.contains(indexValue) ?? false) {
                indexes[keyName]?.saveDB(keyName)
            } else {
                indexesRegister[savedIndexsDBName]?.remove(at: index)
                indexes[keyName] = nil
            }
        }
    }
    
    enum table {
        case indexes
        case deletions
    }

}
