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
    public typealias completion = ([T]?) -> ()
    public typealias count = (Int) -> ()
    public typealias onSingleCompletion = (T?) -> ()
    public typealias onMultCompletion = ([T?]) -> ()
    
    public init(name: String? = nil) {
        self.name = name ?? T.dbName
        queue.async { [weak self] in
            guard let self = self else { return }
            self.objects = [T].loadDB(self.name) ?? []
            guard let newKeysIndexs = IndexesManager.shared.loadDB(withName: self.name, noDBIndexes: T.noDBIndexes) else { return}
            self.loadNewIndexes(with: newKeysIndexs)
        }

//        NotificationCenter.default.addObserver(self, selector: #selector(saveDB), name: UIScene.didDisconnectNotification, object: nil)
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: UIScene.didDisconnectNotification, object: nil)
//    }
    
    private func loadNewIndexes(with positions: [Int]) {
        guard let validObjs = objects.getAllValid() else { return }
        for obj in validObjs {
            obj.updateIndexes(forIndexsAt: positions, withDBName: self.name)
        }
    }
    
    @objc public func saveDB(){
        queue.async { [weak self] in
            guard let self = self else { return }
            self.objects.saveDB()
            IndexesManager.shared.saveDB(with: self.name, noDBIndexes: T.noDBIndexes)
        }
    }
    
    public func save(obj: T, completion: onSingleCompletion? = nil) {
        save(obj: [obj]) { (objs) in
            guard let first = objs.first else { completion?(nil)
                return
            }
            completion?(first)
        }
    }
    
    public func save(obj: [T], completion: onMultCompletion? = nil) {
        queue.async { [weak self] in
            guard let self = self else { return }
            var objsAdded: [T?] = []
            for obj in obj {
                var obj: T? = obj
                self.objects.save(&obj, withDBName: self.name)
                objsAdded.append(obj)
            }
            completion?(objsAdded)
        }
    }
    
    public func delete(obj: T) {
        delete(obj: [obj])
    }
    
    public func delete(obj: [T]) {
        queue.async { [weak self] in
            guard let self = self else { return }
            for obj in obj {
                self.objects.delete(obj, withDBName: self.name)
            }
        }
    }
    
    public func count(completion: count?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            completion?(self.objects.countValid(withDBName: self.name))
        }
    }
    
    public func searchObj(withKey key: String, value: Any, completion: onSingleCompletion?) {
        queue.async { [weak self] in
            guard let self = self else {
                completion?(nil)
                return
            }
            let obj = self.objects.object(with: key, value: value, withDBName: self.name)
            completion?(obj)
        }
    }
    
    public func searchObjs(withKey key: String, lowerValue: Any, lowerOpt: LowerOperator, upperValue: Any, upperOpt: UpperOperator, limit: Int?, bound: Bound, completion: completion?) {
        queue.async { [weak self] in
            guard let self = self else {
                completion?(nil)
                return
            }
             completion?(self.objects.searchRange(with: key, lowerValue: lowerValue, lowerOpt: lowerOpt, upperValue: upperValue, upperOpt: upperOpt, limit: limit, bound: bound))
        }
    }
    
    public func searchObjs(withKey key: String, value: Any, withOp operatr: ExclusiveOperator, limit: Int?, skip: Int? = nil, completion: completion?) {
        queue.async { [weak self] in
            guard let self = self else {
                completion?(nil)
                return
            }
            completion?(self.objects.searchRange(with: key, value: value, withOp: operatr, limit: limit, skip: skip))
        }
    }
    
    public func getAll(completion: completion?) {
        queue.async { [weak self] in
            guard let self = self else {
                completion?(nil)
                return
            }
            completion?(self.objects.getAllValid())
        }
    }
    
    public func delete(){
        queue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.objects.deleteDB()
            IndexesManager.shared.deleteDB(with: self.name, noDBIndexes: T.noDBIndexes)
        }
    }
    
}
