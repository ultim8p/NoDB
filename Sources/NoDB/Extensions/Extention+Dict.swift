//
//  File.swift
//  
//
//  Created by Ita on 7/1/20.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    func indexValue() -> Int? {
        guard let indexValue = self["index"], let index = indexValue as? Int else { return nil }
        return index
    }
}

