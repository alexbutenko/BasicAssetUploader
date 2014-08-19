//
//  Image.swift
//  CloudKitShareImagesPrototype
//
//  Created by alexbutenko on 7/7/14.
//  Copyright (c) 2014 SUSH Mobile. All rights reserved.
//

import Foundation
import CoreData

@objc(Image)
class Image : NSManagedObject {
    @NSManaged var assetID:String
    @NSManaged var fileName:String
    @NSManaged var timestamp:NSDate
    @NSManaged var latitude:NSNumber
    @NSManaged var longitude:NSNumber
    @NSManaged var locationDescription:String!
    @NSManaged var author:Author
    
    var localFilePath:String {
        get {
            let directoryPath = NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask,   appropriateForURL: nil, create: true, error: nil).path

            return directoryPath.stringByAppendingPathComponent(fileName)
        }
    }
}