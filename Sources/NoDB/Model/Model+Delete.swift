//
//  Model+Delete.swift
//  RIDB
//
//  Created by Ita on 6/24/20.
//  Copyright © 2020 rise. All rights reserved.
//

import Foundation

extension Array where Element: DBModel {
    
    mutating func delete(_ obj: Element) {
        guard let id = obj._id else {
            return
        }
        let binaryObj = objectAndIndex(withId: id)
        guard let oldObj = binaryObj.obj, let _ = binaryObj.index else { return }
        oldObj.deleteIndexes()
    }
}
