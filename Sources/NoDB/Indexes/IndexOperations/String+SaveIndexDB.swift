//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

extension Array where Element == String {
    
    func saveIndexList<T: DBModel>(for obj: T, withDBName dbName: String, indexesManager: IndexesManager) {
        for indexName in self {
            indexesManager.insertToSavedIndexes(with: dbName, indexName: indexName)
        }
        indexesManager.insertToSavedIndexes(with: dbName, indexName: NoDBConstant.id.rawValue)
    }
}
