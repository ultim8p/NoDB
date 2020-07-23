//
//  File.swift
//  
//
//  Created by Guerson Perez on 23/07/20.
//

import Foundation

extension Array where Element == String {
    
    func saveIndexList<T: DBModel>(for obj: T, withDBName dbName: String) {
        for indexName in self {
            IndexesManager.shared.insertToSavedIndexes(with: dbName, indexName: indexName)
        }
        IndexesManager.shared.insertToSavedIndexes(with: dbName, indexName: NoDBConstant.id.rawValue)
    }
}
