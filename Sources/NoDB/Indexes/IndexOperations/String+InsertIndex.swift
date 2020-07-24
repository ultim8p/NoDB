//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

extension Array where Element == String {
    /// Creates indexes of properties in the model object for this list of index key names.
    /// - Note: Id indexes will be automatically created for all objects.
    /// - Parameters:
    ///     - obj: Model object from which to extract index values from.
    ///     - dbName: Database name in which the object is being stored. Index databases have related names to this value.
    ///     - idKey: Id property name of the object. We will extract the value for the object's id using this key.
    func insertIndexes<T: DBModel>(for obj: T, withDBName dbName: String, idKey: String, indexesManager: IndexesManager) {
        let objDict = obj.toDictionary()
        let noDBIndexKey = NoDBConstant.index.rawValue
        let noDBIdKey = NoDBConstant.id.rawValue
        guard let objIndex = objDict[noDBIndexKey],
            let objId = objDict[idKey] else { return }
        for indexKey in self {
            // Ignore id if it is defined as an indexable key.
            if indexKey == idKey { continue }
            let indexDBName =  dbName + ":" + indexKey
            if let indexPropertyVal = objDict[indexKey] {
                let dictObj: [String: Any] = [indexKey: indexPropertyVal,
                                              noDBIndexKey: objIndex]
                indexesManager.insert(indexDBName: indexDBName, sortKey: indexKey, indexDict: dictObj)
            }
        }
        
        // Automatically index noDBId for all objects.
        let idIndexDict: [String: Any] = [noDBIdKey: objId,
                                          noDBIndexKey: objIndex]
        indexesManager.insert(indexDBName: dbName + ":" + noDBIdKey,
                              sortKey: noDBIdKey,
                              indexDict: idIndexDict)
    }
}
