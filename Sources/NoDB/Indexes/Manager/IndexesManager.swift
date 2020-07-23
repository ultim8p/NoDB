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
    private let queue = DispatchQueue(customType: .indexesManager)

    private var indexesNamesSaved: [String: [[String: Any]]] = [:]
    private var indexes: [String: [[String: Any]]] = [:]
    private var deletions: [String: [[String: Any]]] = [:]
    
    
    func get(withType type: IndexesType, indexDBName: String) -> [[String: Any]]? {
        queue.sync {
            switch type {
            case .indexes:
                return indexes[indexDBName]
            case .deletions:
                return deletions[indexDBName]
            }
        }
    }
    
    /// Inserts a new index dictionary into the specified index database.
    /// - Parameters:
    ///     - indexType: Type of the index to be inserted in the database.
    ///     - indexDBName: Name of the index database in which the new index dictionary will be inserted to.
    ///     - sortKey: Key name by which indexes are sorted. All indexed dictionaries must have a value for this key.
    ///     - indexDict: Dictionary representing the index to be inserted.
    func insert(indexType: IndexesType = .indexes, indexDBName: String, sortKey: String, indexDict: [String: Any]) {
        queue.sync {
            switch indexType {
            case .indexes:
                if indexes[indexDBName] == nil {
                    indexes[indexDBName] = []
                }
                self.indexes[indexDBName]?.insert(indexDict, key: sortKey)
            case .deletions:
                if deletions[indexDBName] == nil {
                    deletions[indexDBName] = []
                }
                deletions[indexDBName]?.insert(indexDict, key: sortKey)
            }
        }
    }
    
    func upsert(indexDBName: String, indexDict: [String: Any], key: String) {
        queue.sync {
            if self.indexes[indexDBName] == nil {
                self.indexes[indexDBName] = []
            }
            self.indexes[indexDBName]?.upsert(indexDict, key: key)
        }
    }
    
    func delete(indexType: IndexesType = .indexes, indexDBName: String, sortKey: String, indexDict: [String: Any]) {
        queue.sync {
            switch indexType {
            case .indexes:
                indexes[indexDBName]?.delete(indexDict, key: sortKey)
            case .deletions:
                deletions[indexDBName]?.delete(indexDict, key: sortKey)
            }
        }
    }

    func loadDB(withName dbName: String, noDBIndexes: [String]?) -> [Int]? {
        queue.sync {
            let typeIndex = type(of: [[String: Any]]())
            let savedIndexsDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
            indexesNamesSaved[savedIndexsDBName] = typeIndex.loadDB(savedIndexsDBName)
            var newKeysIndexs: [Int] = []
            for (index, indexName) in (noDBIndexes ?? []).enumerated() {
                let indexKey = dbName + ":" + indexName
                if let _ = indexesNamesSaved[savedIndexsDBName]?.binarySearch(key: NoDBConstant.indexSaved.rawValue, value: indexName).currentIndex {
                    indexes[indexKey] = typeIndex.loadDB(indexKey)
                } else {
                    performInsertToSavedIndexes(with: dbName, indexName: indexName)
                    newKeysIndexs.append(index)
                }
            }
            let deletedDBName = IndexesNameType.deleted.getFullName(with: dbName)
            deletions[deletedDBName] = typeIndex.loadDB(deletedDBName)
            return !newKeysIndexs.isEmpty ? newKeysIndexs : nil
        }
    }
    
    func saveDB(with dbName: String, noDBIndexes: [String]?) {
        queue.sync {
            updateAndSavedIndexes(with: dbName, noDBIndexes: noDBIndexes)
            let savedIndexsDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
            let deletedIndexsDBName = IndexesNameType.deleted.getFullName(with: dbName)
            indexesNamesSaved[savedIndexsDBName]?.saveDB(savedIndexsDBName)
            deletions[deletedIndexsDBName]?.saveDB(deletedIndexsDBName)
        }
    }
    
    func deleteDB(with dbName: String, noDBIndexes: [String]?) {
        queue.sync {
            let savedIndexsDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
                _ = indexesNamesSaved[savedIndexsDBName]?.deleteDB(savedIndexsDBName)
            for key in noDBIndexes ?? [] {
                let keyName = dbName + ":" + key
                indexes[keyName]?.deleteDB(keyName)
            }
            let deletedIndexsDBName = IndexesNameType.deleted.getFullName(with: dbName)
                deletions[deletedIndexsDBName]?.deleteDB(deletedIndexsDBName)
        }
    }

    func saveDB() {
        queue.sync {
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
    }
    
    func insertToSavedIndexes(with dbName: String, indexName: String) {
        queue.async {
            self.performInsertToSavedIndexes(with: dbName, indexName: indexName)
        }
    }
    
    private func performInsertToSavedIndexes(with dbName: String, indexName: String){
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
