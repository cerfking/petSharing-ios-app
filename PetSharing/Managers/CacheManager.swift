//
//  CacheManager.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/24.
//

import Foundation

class CacheManager {
    static let shared = CacheManager()
    private init(){}
    
    public func clearAllModelFilesFromDirectory() {

       let fileManager = FileManager.default
       let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
       let documentsPath = documentsUrl.path

       do {
           if let documentPathValue = documentsPath{

               let path = documentPathValue.replacingOccurrences(of: "file://", with: "")
               let fileNames = try fileManager.contentsOfDirectory(atPath: "\(path)")
               print("all files in cache: \(fileNames)")

               for fileName in fileNames {

                   let tempPath = String(format: "%@/%@", path, fileName)

                   //Check for specific file which you want to delete. For me .usdz files
                   if tempPath.contains(".usdz") {
                       try fileManager.removeItem(atPath: tempPath)
                   }
               }
           }

       } catch {
           print("Could not clear document directory \(error)")
       }
   }
}
