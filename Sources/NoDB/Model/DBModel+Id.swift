//
//  DBModel+Id.swift
//  
//
//  Created by Guerson Perez on 6/11/21.
//

import Foundation

extension DBModel {
    
    func modelId(idKey: String) -> Any? {
        return modelStringValue(for: idKey) ?? modelIntValue(for: idKey)
    }
    
    func idEquals(to obj: DBModel, idKey: String) -> Bool {
        let selfId = modelId(idKey: idKey)
        let objId = obj.modelId(idKey: idKey)
        if let selfIdString = selfId as? String,
           let objIdString = objId as? String,
           selfIdString == objIdString {
            return true
        } else if let selfIdInt = selfId as? Int,
                  let objIdInt = objId as? Int,
                  selfIdInt == objIdInt {
            return true
        }
        return false
    }
}
