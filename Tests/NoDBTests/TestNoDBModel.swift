//
//  File.swift
//  
//
//  Created by Guerson on 2020-07-27.
//

import Foundation
import NoDB

struct TestNoDBModel: DBModel {
    var noDBIndex: Int?
    var _id: String?
    var dateValue: Date?
    var intValue: Int?
//    var randonDouble: Double?
//    var randomFloat: Float?
    var boolValue: Bool?
    var text: String?
    
    static var noDBIndexes: [String]? = ["intValue", "dateValue", "text", "boolValue"]
    
}
