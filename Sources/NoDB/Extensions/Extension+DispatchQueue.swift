//
//  File.swift
//  
//
//  Created by Ita on 7/3/20.
//

import Foundation

extension DispatchQueue {
    
    convenience init(customType: customType) {
        switch customType {
        case .noDBQueue:
            self.init(label: customType.rawValue, qos: customType.qos)
        case .indexesManager:
            self.init(label: customType.rawValue, qos: customType.qos, attributes: .concurrent)
        }
    }
    
    enum customType: String {
        case noDBQueue = "NoDBQueue"
        case indexesManager = "IndexesManagerQueue"
        
        var qos: DispatchQoS {
            switch self {
            case .noDBQueue, .indexesManager:
                return DispatchQoS.userInitiated
            }
        }
    }
}
