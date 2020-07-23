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
    
    public typealias ModelCompletion = (T?) -> ()
    public typealias ModelsCompletion = ([T]?) -> ()
    public typealias VoidCompletion = () -> ()
    
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
    
    // MARK: Query
    
    public func find(_ query: Query?, sort: Sort? = nil, skip: Int? = nil, limit: Int? = nil, completion: ModelsCompletion?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let results = self.objects.find(query, dbName: self.name, sort: sort, skip: skip, limit: limit, idKey: self.idKey)
            DispatchQueue.main.async {
                completion?(results)
            }
        }
    }
    
    // MARK: Delete
    
    public func delete(_ query: Query, completion: ModelsCompletion? = nil) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let results = self.objects.delete(query, dbName: self.name, idKey: self.idKey)
            DispatchQueue.main.async {
                completion?(results)
            }
        }
    }
    
    // MARK: Save
    
    public func save(obj: T, completion: ModelCompletion? = nil) {
        save(obj: [obj]) { objs in
            DispatchQueue.main.async {
                completion?(objs?.first)
            }
        }
    }
    
    public func save(obj: [T], completion: ModelsCompletion? = nil) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let objsSaved = self.objects.save(obj, withDBName: self.name, idKey: self.idKey)
            DispatchQueue.main.async {
                completion?(objsSaved)
            }
        }
    }
    
    // MARK: DatabaseFile
    
    public func saveDB(_ handler: VoidCompletion? = nil){
        queue.async { [weak self] in
            guard let self = self else { return }
            self.objects.saveDB(self.name)
            IndexesManager.shared.saveDB(with: self.name, noDBIndexes: T.noDBIndexes)
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    public func deleteDB(_ handler: VoidCompletion? = nil){
        queue.async { [weak self] in
            guard let self = self else { return }
            self.objects.deleteDB(self.name)
            IndexesManager.shared.deleteDB(with: self.name, noDBIndexes: T.noDBIndexes)
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    
    private func loadNewIndexes(with positions: [Int]) {
        guard let validObjs = self.objects.getAllValid(withDBName: self.name) else { return }
        for obj in validObjs {
            obj.updateIndexes(forIndexsAt: positions, withDBName: self.name)
        }
    }
}
