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
    private var indexesManager = IndexesManager()
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
            guard let newNoDBIndexs = self.indexesManager.loadDB(withName: self.name, noDBIndexes: T.noDBIndexes) else { return }
            self.loadNewIndexes(with: newNoDBIndexs)
        }
    }
    
    // MARK: Query
    
    public func find(_ query: Query? = nil, sort: Sort? = nil, skip: Int? = nil, limit: Int? = nil, completion: ModelsCompletion?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let results = self.objects.find(query, dbName: self.name, sort: sort, skip: skip, limit: limit, idKey: self.idKey, indexesManager: self.indexesManager)
            DispatchQueue.main.async {
                completion?(results)
            }
        }
    }
    
    public func findFirst(_ query: Query? = nil, completion: ModelCompletion?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let result = self.objects.findFirst(query, dbName: self.name, idKey: self.idKey, indexesManager: self.indexesManager)
            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }
    
    public func findFirstSync(_ query: Query? = nil) -> T? {
        queue.sync { [weak self] in
            guard let self = self else { return  nil }
            let result = self.objects.findFirst(query, dbName: self.name, idKey: self.idKey, indexesManager: self.indexesManager)
            return result
        }
    }
    
    // MARK: Query
    
    public func findSync(_ query: Query? = nil, sort: Sort? = nil, skip: Int? = nil, limit: Int? = nil)  -> [T]? {
        queue.sync {
            let results = self.objects.find(query, dbName: self.name, sort: sort, skip: skip, limit: limit, idKey: self.idKey, indexesManager: self.indexesManager)
            return results
        }
    }
    
    // MARK: Delete
    
    public func delete(_ query: Query, completion: ModelsCompletion? = nil) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let results = self.objects.delete(query, dbName: self.name, idKey: self.idKey, indexesManager: self.indexesManager)
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
            let objsSaved = self.objects.save(obj, withDBName: self.name, idKey: self.idKey, indexesManager: self.indexesManager)
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
            self.indexesManager.saveDB(with: self.name, noDBIndexes: T.noDBIndexes)
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    public func deleteDB(_ handler: VoidCompletion? = nil){
        queue.async { [weak self] in
            guard let self = self else { return }
            self.objects.deleteDB(self.name)
            self.indexesManager.deleteDB(with: self.name, noDBIndexes: T.noDBIndexes)
            DispatchQueue.main.async {
                handler?()
            }
        }
    }
    
    
    private func loadNewIndexes(with newNoDBIndexes: [String]) {
        guard let validObjs = self.objects.getAllValid(withDBName: self.name, indexesManager: indexesManager) else { return }
        for obj in validObjs {
            obj.updateIndexes(newNoDBIndexes: newNoDBIndexes, withDBName: self.name, indexesManager: indexesManager)
        }
    }
}
