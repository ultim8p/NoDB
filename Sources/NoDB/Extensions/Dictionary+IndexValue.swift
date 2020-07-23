//
//  File.swift
//  
//
//  Created by Ita on 7/1/20.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    /// Returns the value of the dictionary for the defined noDBIndex key.
    /// - Returns: The integer value for the index key.
    func indexValue() -> Int? {
        guard let indexValue = self[NoDBConstant.index.rawValue], let index = indexValue as? Int else { return nil }
        return index
    }
}

