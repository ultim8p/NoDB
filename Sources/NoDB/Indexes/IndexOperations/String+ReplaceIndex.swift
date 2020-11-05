//
//  File.swift
//  
//
//  Created by Guerson on 2020-10-02.
//

import Foundation

extension Array where Element == String {
    func replaceIndexes<T: DBModel>(for oldObj: T, with newObj: T, withDBName dbName: String, idKey: String, indexesManager: IndexesManager) {
        let oldObjDict = oldObj.toDictionary()
        let newObjDict = newObj.toDictionary()
        let noDBIndexKey = NoDBConstant.index.rawValue
        guard let objIndex = oldObjDict[noDBIndexKey],
            oldObjDict[idKey] != nil,
            newObjDict[idKey] != nil else { return }
        
        // Loops through index keys and deletes the index dictionary for the specific key and index.
        for indexKey in self {
            // Ignore id if it is defined as an indexable key.
            if indexKey == idKey { continue }
            let indexDBName = dbName + ":" + indexKey
            
            if let oldIndexVal = oldObjDict[indexKey] {
                let dictObj: [String: Any] = [indexKey: oldIndexVal,
                                              noDBIndexKey: objIndex]
                indexesManager.delete(indexDBName: indexDBName, sortKey: indexKey, indexDict: dictObj)
            }
            
            if let newIndexVal = newObjDict[indexKey] {
                let dictObj: [String: Any] = [indexKey: newIndexVal,
                                              noDBIndexKey: objIndex]
                indexesManager.insert(indexDBName: indexDBName, sortKey: indexKey, indexDict: dictObj)
            }
        }
    }
}
