//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

extension Array where Element == String {
    
    func updateIndexes<T: DBModel>(for obj: T, newObj: T, withDBName dbName: String, idKey: String, indexesManager: IndexesManager) {
        let objDict = obj.toDictionary()
        let newObjDict = newObj.toDictionary()
        let noDBIndexKey = NoDBConstant.index.rawValue
        guard let objIndex = objDict[noDBIndexKey] else { return }
        for (indexKey, newIndexVal) in newObjDict {
            // Ignore id if it is defined as an indexable key.
            if indexKey == idKey { continue }
            if self.contains(indexKey) {
                let indexDBName =  dbName + ":" + indexKey
                if let indexVal = objDict[indexKey] {
                    let dictObj: [String: Any] = [indexKey: indexVal,
                                                  noDBIndexKey: objIndex]
                    indexesManager.delete(indexDBName: indexDBName,
                                                 sortKey: indexKey,
                                                 indexDict: dictObj)
                }
                let newDictObj: [String: Any] = [indexKey: newIndexVal,
                                                 noDBIndexKey: objIndex]
                indexesManager.insert(indexDBName: indexDBName,
                                             sortKey: indexKey,
                                             indexDict: newDictObj)
            }
        }
        
        // TODO: Check if we need to update default indexed id values?
        // We shouldn't since changing the id value of the object would mean it is a new object.
    }
    
    func updateIndex<T: DBModel>(for obj: T, newNoDBIndexes: [String], withDBName dbName: String, indexesManager: IndexesManager) {
        for indexKey in newNoDBIndexes {
            let objDict = obj.toDictionary()
            guard let objIndex = objDict[NoDBConstant.index.rawValue], let indexVal = objDict[indexKey] else { return }
            let indexDBName =  dbName + ":" + indexKey
            let newDictObj: [String: Any] = [indexKey: indexVal,
                                             NoDBConstant.index.rawValue: objIndex]
            indexesManager.insert(indexDBName: indexDBName,
                                  sortKey: indexKey,
                                  indexDict: newDictObj)
        }
    }
}
