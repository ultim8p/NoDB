//
//  File.swift
//  
//
//  Created by Guerson on 2020-07-21.
//

import Foundation
import BinarySearch

extension Array where Element == [String: Any] {
    
    mutating func delete(_ obj: Element, key: String) {
        guard let value = obj[key], let index = obj[NoDBConstant.index.rawValue] else { return }
        let indexQ = self.binarySearch(withIndex: index, key: key, value: value)
        if let itemIndex = indexQ?.index {
            self.remove(at: itemIndex)
        }
    }
}
