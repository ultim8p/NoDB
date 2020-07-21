//
//  File.swift
//  
//
//  Created by Ita on 7/3/20.
//

import Foundation

extension DispatchQueue {
    
    convenience init(customType: customType) {
        self.init(label: customType.rawValue, qos: customType.qos)
    }
    
    enum customType: String {
        case noDBQueue = "NoDBQueue"
        
        var qos: DispatchQoS {
            switch self {
            case .noDBQueue:
                return DispatchQoS.userInitiated
            }
        }
    }
}
