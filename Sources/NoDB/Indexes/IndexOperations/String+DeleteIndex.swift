//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

extension Array where Element == String {
    /// Deletes all existing indexes for the specified object.
    /// Will save a reference by object id in the deletions database to keep track of deleted objects.
    func deleteIndexes<T: DBModel>(for obj: T, withDBName dbName: String, idKey: String) {
        let objDict = obj.toDictionary()
        let noDBIndexKey = NoDBConstant.index.rawValue
        let noDBIdKey = NoDBConstant.id.rawValue
        guard let objIndex = objDict[noDBIndexKey],
            let objId = objDict[idKey] else { return }
        
        // Loops through index keys and deletes the index dictionary for the specific key and index.
        for indexKey in self {
            // Ignore id if it is defined as an indexable key.
            if indexKey == idKey { continue }
            let indexDBName = dbName + ":" + indexKey
            if let indexVal = objDict[indexKey] {
                let dictObj: [String: Any] = [indexKey: indexVal,
                                              NoDBConstant.index.rawValue: objIndex]
                IndexesManager.shared.delete(indexDBName: indexDBName, sortKey: indexKey, indexDict: dictObj)
            }
        }
        
        // Delete default noDBId indexed object.
        let idIndexDict: [String: Any] = [noDBIdKey: objId,
                                          noDBIndexKey: objIndex]
        IndexesManager.shared.delete(indexDBName: dbName + ":" + noDBIdKey,
                                     sortKey: noDBIdKey,
                                     indexDict: idIndexDict)
        
        // Save a deleted object in the deletions indexes database by the object's id.
        let deletionReferenceDict: [String: Any] = [NoDBConstant.id.rawValue: objId,
                                             NoDBConstant.index.rawValue: objIndex]
        IndexesManager.shared.insert(indexType: .deletions,
                                     indexDBName: IndexesNameType.deleted.getFullName(with: dbName),
                                     sortKey: idKey,
                                     indexDict: deletionReferenceDict)
    }
}
