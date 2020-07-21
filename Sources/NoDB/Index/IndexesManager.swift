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

    private var indexesRegister: [String: [String]] = [:]
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
        indexesRegister[model.indexsRegisterdbName] = [String].loadDB(model.indexsRegisterdbName)
        var newKeysIndexs: [Int] = []
        for (index, key) in (model.indexes ?? []).enumerated() {
            let indexKey = dbName + ":" + key
            if let _ = indexesRegister[model.indexsRegisterdbName]?.binarySearch(key).currentIndex {
                indexes[indexKey] = typeIndex.loadDB(indexKey)
            } else {
                insertToRegister(indxsRdbname: model.indexsRegisterdbName, key: key)
                newKeysIndexs.append(index)
            }
        }
        let deletedDBName = model.deletedIndexdbName
        deletions[deletedDBName] = typeIndex.loadDB(deletedDBName)
        return !newKeysIndexs.isEmpty ? newKeysIndexs : nil
    }
    
    func saveDB<T: DBModel>(for model: T.Type) {
        let dbName = model.dbName
        for (index, key) in (indexesRegister[model.indexsRegisterdbName] ?? []).enumerated() {
            let keyName = dbName + ":" + key
            if !(model.indexes?.contains(key) ?? false) {
                indexesRegister[dbName]?.remove(at: index)
                indexes[keyName] = nil
            } else {
                indexes[keyName]?.saveDB(keyName)
            }
        }
        indexesRegister[model.indexsRegisterdbName]?.saveDB(model.indexsRegisterdbName)
        deletions[model.deletedIndexdbName]?.saveDB(model.deletedIndexdbName)
    }
    
    func deleteDB<T: DBModel>(for model: T.Type) {
        let dbName = model.dbName
        _ = indexesRegister[model.indexsRegisterdbName]?.deleteDB(model.indexsRegisterdbName)
        for key in model.indexes ?? [] {
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
    
    func insertToRegister(indxsRdbname: String, key: String) {
        if indexesRegister[indxsRdbname] == nil {
            indexesRegister[indxsRdbname] = []
        }
        indexesRegister[indxsRdbname]?.upsert(key)
    }
    
    enum table {
        case indexes
        case deletions
    }

}
