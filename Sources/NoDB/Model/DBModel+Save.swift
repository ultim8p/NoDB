//
//  File.swift
//  
//
//  Created by Ita on 7/5/20.
//

import Foundation

extension Array where Element: DBModel {
    
    @discardableResult
    mutating func save(elements: [Element], by key: String) -> [Element] {
        var changes: [Element] = []
        var dicts = self.map { $0.toDictionary() }
        for element in elements {
            let newDict = element.toDictionary()
            guard let value = newDict[key] else {
                continue
            }
            let searchResult = dicts.binarySearch(key: key, value: value)
            if let currentIndex = searchResult.currentIndex {
                guard let updatedObj = dicts[currentIndex].merge(with: newDict)?.toModel(Element.self) else {
                    continue
                }
                self[currentIndex] = updatedObj
                changes.append(updatedObj)
            } else if let insertIn = searchResult.insertInIndex {
                self.insert(element)
                dicts.insert(newDict, at: insertIn)
                changes.append(element)
            }
        }
        return changes
    }
    
}
