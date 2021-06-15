//
//  File.swift
//  
//
//  Created by Guerson on 2020-07-23.
//

import Foundation

struct SaveModel <T: DBModel> {
    var element: T
    var noDBId: Any
}
