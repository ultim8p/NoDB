//
//  File.swift
//  
//
//  Created by Ita on 7/2/20.
//

import Foundation
import Mergeable

/// A set of methods to manage database indexes.
/// Every indexable key in an object will have
extension Array where Element == String {
    
    func deleteIndexes<T: DBModel>(for obj: T, withDBName dbName: String) {
        let objDict = obj.toDictionary()
        guard let objIndex = objDict[NoDBConstant.index.rawValue] else { return }
        for indexKey in self {
            let indexDBName =  dbName + ":" + indexKey
            if let indexVal = objDict[indexKey] {
                let dictObj: [String: Any] = [indexKey: indexVal,
                                              NoDBConstant.index.rawValue: objIndex]
                IndexesManager.shared.delete(indexDBName: indexDBName, indexDict: dictObj, key: indexKey)
            }
        }
        let indexKey = "_id"
        guard let indexVal = objDict[indexKey] else { return }
        let deletedDictObj: [String: Any] = [indexKey: indexVal,
                                             NoDBConstant.index.rawValue: objIndex]
        IndexesManager.shared.insert(in: .deletions, indexDBName: IndexesNameType.deleted.getFullName(with: dbName), indexDict: deletedDictObj, key: indexKey)
    }
    
    func insertIndexes<T: DBModel>(for obj: T, withDBName dbName: String) {
        let objDict = obj.toDictionary()
        guard let objIndex = objDict[NoDBConstant.index.rawValue] else { return }
        for indexKey in self {
            let indexDBName =  dbName + ":" + indexKey
            if let indexVal = objDict[indexKey] {
                let dictObj: [String: Any] = [indexKey: indexVal,
                                              NoDBConstant.index.rawValue: objIndex]
                IndexesManager.shared.insert(indexDBName: indexDBName, indexDict: dictObj, key: indexKey)
            }
        }
    }
    
    func upsertIndexes<T: DBModel>(for obj: T, withDBName dbName: String) {
        let objDict = obj.toDictionary()
        guard let objIndex = objDict[NoDBConstant.index.rawValue] else { return }
        for indexKey in self {
            let indexDBName =  dbName + ":" + indexKey
            if let indexVal = objDict[indexKey] {
                let dictObj: [String: Any] = [indexKey: indexVal,
                                              NoDBConstant.index.rawValue: objIndex]
                IndexesManager.shared.upsert(indexDBName: indexDBName, indexDict: dictObj, key: indexKey)
            }
        }
    }
    
    func updateIndexes<T: DBModel>(for obj: T, newObj: T, withDBName dbName: String) {
        let objDict = obj.toDictionary()
        let newObjDict = newObj.toDictionary()
        guard let objIndex = objDict[NoDBConstant.index.rawValue] else { return }
        for (indexKey, newIndexVal) in newObjDict {
            if self.contains(indexKey) {
                let indexDBName =  dbName + ":" + indexKey
                if let indexVal = objDict[indexKey] {
                    let dictObj: [String: Any] = [indexKey: indexVal,
                                                  NoDBConstant.index.rawValue: objIndex]
                    IndexesManager.shared.delete(indexDBName: indexDBName, indexDict: dictObj, key: indexKey)
                }
                let newDictObj: [String: Any] = [indexKey: newIndexVal,
                                                 NoDBConstant.index.rawValue: objIndex]
                IndexesManager.shared.insert(indexDBName: indexDBName, indexDict: newDictObj, key: indexKey)
            }
        }
     }
    
    func updateIndex<T: DBModel>(for obj: T, forIndexsAt indexs: [Int], withDBName dbName: String) {
        for index in indexs {
            let indexKey = self[index]
            let objDict = obj.toDictionary()
            guard let objIndex = objDict[NoDBConstant.index.rawValue], let indexVal = objDict[indexKey] else { return }
            let indexDBName =  dbName + ":" + indexKey
            let newDictObj: [String: Any] = [indexKey: indexVal,
                                             NoDBConstant.index.rawValue: objIndex]
            IndexesManager.shared.insert(indexDBName: indexDBName, indexDict: newDictObj, key: indexKey)
        }
    }
    
    func saveIndexList<T: DBModel>(for obj: T, withDBName dbName: String) {
        for indexName in self {
            IndexesManager.shared.insertToSavedIndexs(with: dbName, indexName: indexName)
        }
    }
}
