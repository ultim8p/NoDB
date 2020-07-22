//
//  DBModel.swift
//  NoDB
//
//  Created by Guerson on 2020-05-23.
//  Copyright © 2020 rise. All rights reserved.
//

import Foundation
import Mergeable

public protocol DBModel: Mergeable {
    var _id: String? { get set }
    var noDBIndex: Int? { get set }
    static var noDBIndexes: [String]? { get }
}

extension Array where Element: DBModel {
    
    func saveTo(_ db: NoDB<Element>, completion: (([Element?]) ->())? = nil) {
        db.save(obj: self, completion: completion)
    }
    
}

