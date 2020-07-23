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
        guard let selfId = self.modelStringValue(for: idKey),
            let objId = obj.modelStringValue(for: idKey),
            selfId == objId else {
             return nil
        }
        let changes = self.merge(with: obj, idKey: idKey)
        return changes
    }
}

