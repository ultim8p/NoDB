//
//  File.swift
//  
//
//  Created by Guerson on 2020-11-05.
//

import Foundation

extension Array {
    func rangeContains(index: Int) -> Bool {
        return index >= 0 && index < self.count
    }
    
    func canInsert(at index: Int) -> Bool {
        return index >= 0 && index <= self.count
    }
}
