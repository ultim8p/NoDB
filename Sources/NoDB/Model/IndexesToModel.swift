//
//  File.swift
//  
//
//  Created by Guerson Perez on 22/07/20.
//

import Foundation

extension Array where Element: DBModel {
    func models(fromIndexes indexes: [[String: Any]]) -> [Element] {
        var results: [Element] = []
        for result in indexes {
            guard let indexValue = result.indexValue() else { continue }
            results.append(self[indexValue])
        }
        return results
    }
}
