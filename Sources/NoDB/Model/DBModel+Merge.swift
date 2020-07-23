//
//  File.swift
//  
//
//  Created by Ita on 7/2/20.
//

import Foundation
import Mergeable

extension DBModel {
    mutating func merge<T: Mergeable>(_ type: T.Type, with obj: T) -> T?  {
        guard let objDM = obj as? Self, let id = self._id, let extId = objDM._id, id == extId else {
            return nil
        }
        let changes = self.merge(with: obj, idKey: "_id")
        return changes
    }
}

