//
//  DBRIModel.swift
//  RIDB
//
//  Created by Ita on 6/29/20.
//  Copyright © 2020 rise. All rights reserved.
//

import Foundation
import BinarySearch

open class NoDB<T: DBModel> {
    
    private var objects: [T] = []
    private let queue = DispatchQueue(customType: .noDBQueue)
    public var name: String
    public var idKey: String
    public typealias completion = ([T]?) -> ()
    public typealias countHandler = (Int) -> ()
    public typealias onSingleCompletion = (T?) -> ()
    public typealias onMultCompletion = ([T]?) -> ()
    
    public init(name: String? = nil, idKey: String = "id") {
        self.name = name ?? T.dbName
        self.idKey = idKey
        queue.async { [weak self] in
            guard let self = self else { return }
            self.objects = [T].loadDB(self.name) ?? []
            guard let newKeysIndexs = IndexesManager.shared.loadDB(withName: self.name, noDBIndexes: T.noDBIndexes) else { return }
            self.loadNewIndexes(with: newKeysIndexs)
        }
    }
    
    public func find(_ query: Query?, sort: Sort? = nil, skip: Int? = nil, limit: Int? = nil, completion: completion?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let results = self.objects.find(query, dbName: self.name, sort: sort, skip: skip, limit: limit, idKey: self.idKey)
            completion?(results)
        }
    }
    
    private func loadNewIndexes(with positions: [Int]) {
        guard let validObjs = self.objects.getAllValid(withDBName: self.name) else { return }
        for obj in validObjs {
            obj.updateIndexes(forIndexsAt: positions, withDBName: self.name)
        }
    }
    
    @objc public func saveDB(){
        queue.async { [weak self] in
            guard let self = self else { return }
        self.objects.saveDB(self.name)
            IndexesManager.shared.saveDB(with: self.name, noDBIndexes: T.noDBIndexes)
        }
    }
    
    public func save(obj: [T], completion: onMultCompletion? = nil) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let objsSaved = self.objects.save(obj, withDBName: self.name, idKey: self.idKey)
            completion?(objsSaved)
        }
    }
    
    public func save(obj: T, completion: onSingleCompletion? = nil) {
        save(obj: [obj]) { objs in
            guard let first = objs?.first else {
                completion?(nil)
                return
            }
            completion?(first)
        }
    }

    
    // TODO: Add delete function based on key values
    /// Deletes a single object from the database using the id key.
//    public func delete(obj: T) {
//        delete(obj: [obj])
//    }
    
    /// Delete multiple objects from the database using the id key.
//    public func delete(obj: [T]) {
//        queue.async { [weak self] in
//            guard let self = self else { return }
//            for obj in obj {
//                self.objects.delete(key: NoDBConstant.id.rawValue, value: sel, dbName: <#T##String#>, idKey: <#T##String#>)
//                self.objects.delete(obj, withDBName: self.name, idKey: self.idKey)
//            }
//        }
//    }
    
//    public func searchObj(withKey key: String, value: Any, completion: onSingleCompletion?) {
//        queue.async { [weak self] in
//            guard let self = self else {
//                completion?(nil)
//                return
//            }
//            let obj = self.objects.object(with: key, value: value, withDBName: self.name)
//            completion?(obj)
//        }
//    }
    
//    public func searchObjs(withKey key: String, lowerValue: Any, lowerOpt: LowerOperator, upperValue: Any, upperOpt: UpperOperator, limit: Int?, bound: Bound, completion: completion?) {
//        queue.async { [weak self] in
//            guard let self = self else {
//                completion?(nil)
//                return
//            }
//            completion?(self.objects.searchRange(with: key, lowerValue: lowerValue, lowerOpt: lowerOpt, upperValue: upperValue, upperOpt: upperOpt, limit: limit, bound: bound, withDBName: self.name))
//        }
//    }
    
//    public func searchObjs(withKey key: String, value: Any, withOp operatr: ExclusiveOperator, limit: Int?, skip: Int? = nil, completion: completion?) {
//        queue.async { [weak self] in
//            guard let self = self else {
//                completion?(nil)
//                return
//            }
//            completion?(self.objects.searchRange(with: key, value: value, operatr: operatr, limit: limit, skip: skip, withDBName: self.name))
//        }
//    }
    
//    public func searchObjs(withKey key: String, value: Any, withOp operatr: LowerOperator, completion: completion?) {
//        queue.async { [weak self] in
//            guard let self = self else {
//                completion?(nil)
//                return
//            }
//            completion?(self.objects.searchRange(with: key, value: value, operatr: operatr, withDBName: self.name))
//        }
//    }
    
//    public func searchObjs(withKey key: String, value: Any, withOp operatr: UpperOperator, completion: completion?) {
//        queue.async { [weak self] in
//            guard let self = self else {
//                completion?(nil)
//                return
//            }
//            completion?(self.objects.searchRange(with: key, value: value, operatr: operatr, withDBName: self.name))
//        }
//    }
    
//    public func getAll(completion: completion?) {
//        queue.async { [weak self] in
//            guard let self = self else {
//                completion?(nil)
//                return
//            }
//            completion?(self.objects.getAllValid(withDBName: self.name))
//        }
//    }
    
    public func deleteDB(){
        queue.async { [weak self] in
            guard let self = self else {
                return
            }
        self.objects.deleteDB(self.name)
            IndexesManager.shared.deleteDB(with: self.name, noDBIndexes: T.noDBIndexes)
        }
    }
    
}
