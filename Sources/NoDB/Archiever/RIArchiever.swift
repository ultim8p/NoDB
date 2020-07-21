//
//  RIArchiever.swift
//  RIDB
//
//  Created by Guerson on 2020-05-23.
//  Copyright © 2020 rise. All rights reserved.
//

import Foundation


class RIArchiever: NSObject {
    
    static func save(fileName: String, object: Any) -> Bool {
        let fileUrl = RIArchiever.filePath(for: fileName)
        let success = NSKeyedArchiver.archiveRootObject(object, toFile: fileUrl)
        return success
    }
    
    static func load(fileName: String) -> Any? {
        let fileUrl = RIArchiever.filePath(for: fileName)
        let file = NSKeyedUnarchiver.unarchiveObject(withFile: fileUrl)
        return file
    }
    
    static func delete(fileName: String) -> Error? {
        let fileUrl = RIArchiever.filePath(for: fileName)
        let exists = FileManager.default.fileExists(atPath: fileUrl)
        if exists {
            do {
                try FileManager.default.removeItem(atPath: fileUrl)
            } catch {
                print("DELET ERR: \(error)")
                return error
            }
        }
        return nil
    }
    
    static func filePath(for fileName: String) -> String {
        //1 - manager lets you examine contents of a files and folders in your app; creates a directory to where we are saving it
        let manager = FileManager.default
        //2 - this returns an array of urls from our documentDirectory and we take the first path
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        //3 - creates a new path component and creates a new file called "Data" which is where we will store our Data array.
        let retUrl = (url?.appendingPathComponent(fileName))!
        
        return retUrl.path
    }
    
    
}

