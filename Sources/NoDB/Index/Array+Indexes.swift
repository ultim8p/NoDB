//
//  File.swift
//  
//
//  Created by Ita on 7/2/20.
//

import Foundation
import Mergeable

extension Array where Element == String {
    
    func deleteIndexes<T: DBModel>(for obj: T) {
        let dbName = obj.dbName
        let objDict = obj.toDictionary()
        guard let objIndex = objDict["index"] else { return }
        for indexKey in self {
            let indexDBName =  dbName + ":" + indexKey
            if let indexVal = objDict[indexKey] {
                let dictObj: [String: Any] = [indexKey: indexVal,
                                                 "index": objIndex]
                IndexesManager.shared.delete(indexDBName: indexDBName, indexDict: dictObj, key: indexKey)
            }
        }
        let indexKey = "_id"
        guard let indexVal = objDict[indexKey] else { return }
        let deletedDictObj: [String: Any] = [indexKey: indexVal,
                                                "index": objIndex]
        IndexesManager.shared.insert(in: .deletions, indexDBName: obj.deletedIndexdbName, indexDict: deletedDictObj, key: indexKey)
    }
    
    func insertIndexes<T: DBModel>(for obj: T) {
        let dbName = obj.dbName
        let objDict = obj.toDictionary()
        guard let objIndex = objDict["index"] else { return }
        for indexKey in self {
            let indexDBName =  dbName + ":" + indexKey
            if let indexVal = objDict[indexKey] {
                let dictObj: [String: Any] = [indexKey: indexVal,
                                                 "index": objIndex]
                IndexesManager.shared.insert(indexDBName: indexDBName, indexDict: dictObj, key: indexKey)
            }
        }
    }
    
    func upsertIndexes<T: DBModel>(for obj: T) {
        let dbName = obj.dbName
        let objDict = obj.toDictionary()
        guard let objIndex = objDict["index"] else { return }
        for indexKey in self {
            let indexDBName =  dbName + ":" + indexKey
            if let indexVal = objDict[indexKey] {
                let dictObj: [String: Any] = [indexKey: indexVal,
                                                 "index": objIndex]
                IndexesManager.shared.upsert(indexDBName: indexDBName, indexDict: dictObj, key: indexKey)
            }
        }
    }
    
    func updateIndexes<T: DBModel>(for obj: T, newObj: T) {
        let dbName = obj.dbName
        let objDict = obj.toDictionary()
        let newObjDict = newObj.toDictionary()
        guard let objIndex = objDict["index"] else { return }
        for (indexKey, newIndexVal) in newObjDict {
            if self.contains(indexKey) {
                let indexDBName =  dbName + ":" + indexKey
                if let indexVal = objDict[indexKey] {
                    let dictObj: [String: Any] = [indexKey: indexVal,
                    "index": objIndex]
                    IndexesManager.shared.delete(indexDBName: indexDBName, indexDict: dictObj, key: indexKey)
                }
                let newDictObj: [String: Any] = [indexKey: newIndexVal,
                "index": objIndex]
                IndexesManager.shared.insert(indexDBName: indexDBName, indexDict: newDictObj, key: indexKey)
            }
        }
     }
    
    func updateIndex<T: DBModel>(for obj: T, forIndexsAt indexs: [Int]) {
        let dbName = obj.dbName
        for index in indexs {
            let indexKey = self[index]
            let objDict = obj.toDictionary()
            guard let objIndex = objDict["index"], let indexVal = objDict[indexKey] else { return }
            let indexDBName =  dbName + ":" + indexKey
            let newDictObj: [String: Any] = [indexKey: indexVal,
                             "index": objIndex]
            IndexesManager.shared.insert(indexDBName: indexDBName, indexDict: newDictObj, key: indexKey)
        }
    }
    
    func saveIndexList<T: DBModel>(for obj: T) {
        for key in self {
            IndexesManager.shared.insertToRegister(indxsRdbname: T.indexsRegisterdbName, key: key)
        }
    }
}
