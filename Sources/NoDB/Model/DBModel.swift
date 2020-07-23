//
//  DBModel.swift
//  NoDB
//
//  Created by Guerson on 2020-05-23.
//  Copyright © 2020 rise. All rights reserved.
//

import Foundation
import Mergeable

/// Core Model of NoDB.
public protocol DBModel: Mergeable {
//    var id: String? { get set }
    
    // For internal use, do not modify or change the value of this property.
    var noDBIndex: Int? { get set }
    
    // Define the name of the properties that the Database should index.
    // Indexes are used to perform efficient operations in the DB.
    // All properties that you need to use to perform queries must be indexed, other wise the queries will not find any object.
    static var noDBIndexes: [String]? { get }
}
