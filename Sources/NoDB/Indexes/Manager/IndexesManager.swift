//
//  File.swift
//  
//
//  Created by Guerson on 2020-07-24.
//

import Foundation

class IndexesManager {

    private let queue = DispatchQueue(customType: .indexesManager)

    private var noDBIndexesSaved: [[String: Any]] = []
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

    func loadDB(withName dbName: String, noDBIndexes: [String]?) -> [String]? {
        queue.sync {
            let noDBIndexes = getCompleteNoDBModelIndexes(with: noDBIndexes)
            let typeIndex = type(of: [[String: Any]]())
            let savedIndexesDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
            noDBIndexesSaved = typeIndex.loadDB(savedIndexesDBName) ?? []
            var newNoDBIndexes: [String] = []
            for indexName in noDBIndexes {
                let indexDBName = dbName + ":" + indexName
                if noDBIndexesSaved.binarySearch(key: NoDBConstant.indexSaved.rawValue, value: indexName).currentIndex != nil {
                    indexes[indexDBName] = typeIndex.loadDB(indexDBName)
                } else {
                    performInsertToSavedIndexes(with: dbName, noDBIndexName: indexName)
                    newNoDBIndexes.append(indexName)
                }
            }
            let deletedDBName = IndexesNameType.deleted.getFullName(with: dbName)
            deletions[deletedDBName] = typeIndex.loadDB(deletedDBName)
            return !newNoDBIndexes.isEmpty ? newNoDBIndexes : nil
        }
    }
    
    func saveDB(with dbName: String, noDBIndexes: [String]?) {
        queue.sync {
            updateAndSavedIndexes(with: dbName, noDBIndexes: noDBIndexes)
            let savedIndexsDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
            let deletedIndexsDBName = IndexesNameType.deleted.getFullName(with: dbName)
            noDBIndexesSaved.saveDB(savedIndexsDBName)
            deletions[deletedIndexsDBName]?.saveDB(deletedIndexsDBName)
        }
    }
    
    func deleteDB(with dbName: String, noDBIndexes: [String]?) {
        queue.sync {
            let savedIndexsDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
            for indexObj in noDBIndexesSaved {
                guard let indexValue = indexObj[NoDBConstant.indexSaved.rawValue] as? String else {
                    continue
                }
                let keyName = dbName + ":" + indexValue
                indexes[keyName]?.deleteDB(keyName)
            }
            noDBIndexesSaved.deleteDB(savedIndexsDBName)
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
//                for keys in noDBIndexesSaved {
//                keys.value.saveDB(keys.key)
//            }
        }
    }
    
    func insertToSavedIndexes(with dbName: String, indexName: String) {
        queue.async {
            self.performInsertToSavedIndexes(with: dbName, noDBIndexName: indexName)
        }
    }
    
    private func performInsertToSavedIndexes(with dbName: String, noDBIndexName: String){
        let savedIndexsDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
        let key = NoDBConstant.indexSaved.rawValue
        let newDict: [String: Any] = [key: noDBIndexName]
            noDBIndexesSaved.upsert(newDict, key: key)
    }

    private func updateAndSavedIndexes(with dbName: String, noDBIndexes: [String]?){
        let savedIndexesDBName = IndexesNameType.savedIndexes.getFullName(with: dbName)
        var noDBIndexes = noDBIndexes
        noDBIndexes?.append(NoDBConstant.id.rawValue)
        for (index, indexObj) in noDBIndexesSaved.enumerated() {
            guard let indexValue = indexObj[NoDBConstant.indexSaved.rawValue] as? String else {
                continue
            }
            let keyName = dbName + ":" + indexValue
            if (noDBIndexes?.contains(indexValue) ?? false) {
                indexes[keyName]?.saveDB(keyName)
            } else {
                noDBIndexesSaved.remove(at: index)
                indexes[keyName] = nil
            }
        }
    }
    
    private func getCompleteNoDBModelIndexes(with modelNoDBIndexes: [String]?) -> [String] {
        var completeModelNoDBIndexes = [NoDBConstant.id.rawValue]
        for noDBIndexName in modelNoDBIndexes ?? [] {
            completeModelNoDBIndexes.append(noDBIndexName)
        }
        return completeModelNoDBIndexes
    }

}
