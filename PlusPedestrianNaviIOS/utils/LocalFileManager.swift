//
//  LocalFileManager.swift
//  PlusPedestrianNaviIOS
//
//  Created by 박정규 on 2018. 10. 2..
//  Copyright © 2018년 박정규. All rights reserved.
//

import UIKit

//로컬에 파일 저장/로딩 관리 
class LocalFileManager {
    
    static var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static public func save(image: UIImage , fileName: String) -> String? {
        
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileName // ----> Save fileName
        }
        print("Error saving image")
        return nil
    }
    
    
    static public func load(fileName: String) -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
}
