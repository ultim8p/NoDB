//
//  File.swift
//  
//
//  Created by Guerson Perez on 22/07/20.
//

import Foundation

extension Array where Element: DBModel {
    func models(fromIndexes indexes: [[String: Any]]?) -> [Element]? {
        var results: [Element] = []
        for result in indexes ?? [] {
            guard let indexValue = result.indexValue(),
                  self.rangeContains(index: indexValue) else { continue }
            results.append(self[indexValue])
        }
        return results.count > 0 ? results : nil
    }
    
    func model(fromIndex index: [String: Any]?) -> Element? {
        guard let indexValue = index?.indexValue(),
              self.rangeContains(index: indexValue) else { return nil }
        let result = self[indexValue]
        return result
    }
}
