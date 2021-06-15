//
//  File.swift
//  
//
//  Created by Ita on 7/2/20.
//

import Foundation
import Mergeable

extension DBModel {
    
    /// Merges a DBModel into self.
    /// Will use ids to merge nested unique objects together.
    mutating func merge<T: DBModel>(_ type: T.Type, with obj: T, idKey: String) -> T?  {
        guard idEquals(to: obj, idKey: idKey) else {
             return nil
        }
        let changes = self.merge(with: obj, idKey: idKey)
        return changes
    }
}

