//
//  ImageCloudManager.swift
//  CloudKitShareImagesPrototype
//
//  Created by alexbutenko on 7/7/14.
//  Copyright (c) 2014 SUSH Mobile. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation

class ImageCloudManager {
    
    class func uploadAssetWithURL(assetURL:NSURL, location:CLLocation, completionHandler:((assetID:String?, error:NSError?) -> Void)) {
        CloudManager.sharedInstance.uploadAssetWithURL(assetURL, location: location, authorID: UserDataManager.sharedInstance.persistedUser!.serverID, {record, error in
            if (nil != record) {
                completionHandler(assetID: record!.recordID.recordName, error: nil)
            } else {
                completionHandler(assetID: nil, error: error)
            }
        })
    }
    
    class func fetchImages(completionHandler:(images:[ImagePlainObject]?, error:NSError?) -> Void) {
        CloudManager.sharedInstance.fetchImages {records, error in
            if (nil == error && nil != records) {
                var images:[ImagePlainObject] = records!.map{record in
                    let asset:CKAsset = record.objectForKey(CloudManager.ModelKeys.AssetValue) as CKAsset
                    let location:CLLocation = record.objectForKey(CloudManager.ModelKeys.AssetLocation) as CLLocation
                
                    let authorReference:CKReference = record.objectForKey(CloudManager.ModelKeys.AssetAuthor) as CKReference
                    
                    let ownerID:String = authorReference.recordID.recordName
                    
//                    println("asset \(asset.fileURL) ownerID \(ownerID) authorRef \(authorReference)")
                    
                    var imageObject = ImagePlainObject(imagePath: asset.fileURL.path, location: location, date: record.creationDate, ownerID: ownerID, identifier: record.recordID.recordName)
                    return imageObject
                }
                
                completionHandler(images: images, error: nil)
            } else {
                completionHandler(images:nil, error:error)
            }
        }
    }
}