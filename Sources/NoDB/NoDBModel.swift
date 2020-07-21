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
    public typealias completion = ([T]?) -> ()
    public typealias count = (Int) -> ()
    public typealias onSingleSaved = (T?) -> ()
    public typealias onMultSaved = ([T?]) -> ()
    
    public init(with type: T.Type) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.objects = [T].loadDB() ?? []
            guard let newKeysIndexs = IndexesManager.shared.loadDB(for: type) else { return }
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
            obj.updateIndexes(forIndexsAt: positions)
        }
    }
    
    @objc public func saveDB(){
        queue.async { [weak self] in
            guard let self = self else { return }
            self.objects.saveDB()
            IndexesManager.shared.saveDB(for: T.self)
        }
    }
    
    public func save(obj: T, completion: onSingleSaved?) {
        save(obj: [obj]) { (objs) in
            guard let first = objs.first else { completion?(nil)
                return
            }
            completion?(first)
        }
    }
    
    public func save(obj: [T], completion: onMultSaved?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            var objsAdded: [T?] = []
            for obj in obj {
                var obj: T? = obj
                self.objects.save(&obj)
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
                self.objects.delete(obj)
            }
        }
    }
    
    public func count(completion: count?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            completion?(self.objects.countValid())
        }
    }
    
    public func searchObjs(with key: String, lowerValue: Any, lowerOpt: LowerOperator, upperValue: Any, upperOpt: UpperOperator, limit: Int?, bound: Bound, completion: completion?) {
        queue.async { [weak self] in
            guard let self = self else { return }
             completion?(self.objects.searchRange(with: key, lowerValue: lowerValue, lowerOpt: lowerOpt, upperValue: upperValue, upperOpt: upperOpt, limit: limit, bound: bound))
        }
    }
    
    public func searchObjs(with key: String, value: Any, withOp operatr: ExclusiveOperator, limit: Int?, skip: Int? = nil, completion: completion?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            completion?(self.objects.searchRange(with: key, value: value, withOp: operatr, limit: limit, skip: skip))
        }
    }
    
    public func getAll(completion: completion?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            completion?(self.objects.getAllValid())
        }
    }
    
    public func delete(){
        queue.async { [weak self] in
            guard let self = self else { return }
            self.objects.deleteDB()
            IndexesManager.shared.deleteDB(for: T.self)
        }
    }
    
}
