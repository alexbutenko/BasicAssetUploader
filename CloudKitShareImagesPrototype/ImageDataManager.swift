//
//  ImageDataManager.swift
//  CloudKitShareImagesPrototype
//
//  Created by alexbutenko on 7/7/14.
//  Copyright (c) 2014 SUSH Mobile. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class ImageDataManager {
    
    var image:ImagePlainObject?
    
    init() {}
    
    init(image:UIImage, location:CLLocation, date:NSDate) {
        self.image = ImagePlainObject(image:image, location:location, date:date)
    }
    
    func saveImage() {
        var imagePersistanceObject:Image = Image.MR_createEntity() as Image
        
        imagePersistanceObject.fileName = cacheResizedImageFromImage(self.image!.image!)
        
        println("local file path \(imagePersistanceObject.localFilePath)")
        
        ImageCloudManager.uploadAssetWithURL(NSURL(fileURLWithPath: imagePersistanceObject.localFilePath), location: self.image!.location, {assetID, error in
            if (nil != assetID) {
                println("asset ID \(assetID)")
                imagePersistanceObject.assetID = assetID!
                NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
            } else {
                var alert = UIAlertController(title: "Error", message: "Failed to upload asset", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                UIApplication.sharedApplication().keyWindow.rootViewController.presentViewController(alert, animated: true, completion: nil)                
            }
        })
        
        imagePersistanceObject.latitude = self.image!.location.coordinate.latitude
        imagePersistanceObject.longitude = self.image!.location.coordinate.longitude
        
        self.locaLocationDescriptionIfNeededForLocation(imagePersistanceObject, location:self.image!.location)
        
        imagePersistanceObject.timestamp = self.image!.date
        imagePersistanceObject.author = UserDataManager.sharedInstance.persistedUser!
        
        NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
    }
    
    //TODO: load once and pass to server
    func locaLocationDescriptionIfNeededForLocation(object:Image, location:CLLocation) -> Void {

        if (!object.locationDescription) {

            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {placemarks, error in
                
                if (nil != error) {
                    println("reverse geodcode fail: \(error.localizedDescription)")
                }
                
                if placemarks.count > 0 {
                    var placemark = CLPlacemark(placemark: placemarks[0] as CLPlacemark)
                    
                    println("source placemark \(placemark.country), \(placemark.locality), \(placemark.subLocality)")
                    
                    object.locationDescription = placemark.country + ", " + placemark.locality + ", " + placemark.subLocality
                    NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
                }
                else {
                    println("No Placemarks!")
                }
            })
        }
    }
    
    func cacheResizedImageFromImage(inImage:UIImage) -> NSString {
        //scale down
        var width:CGFloat = 512.0
        var height:CGFloat = 512.0
        var imageWidth = inImage.size.width
        var imageHeight = inImage.size.height
        
        if (inImage.size.width > inImage.size.height) {
            height = width * imageHeight / imageWidth
        } else {
            width = height * imageWidth / imageHeight
        }
        
        var newSize:CGSize = CGSizeMake(width, height)
        
        UIGraphicsBeginImageContext(newSize)
        inImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        let imageData = UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(), 0.75)
        UIGraphicsEndImageContext()
        
        // write the image out to a cache file
        let directoryPath = NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: nil).path
        let temporaryName = NSUUID.UUID().UUIDString.stringByAppendingPathExtension("jpeg")
        let localPath = directoryPath.stringByAppendingPathComponent(temporaryName)
        
        imageData.writeToFile(localPath, atomically: true)
        
        return temporaryName
    }
    
    func fetchImages(completionHandler:(error:NSError?) -> Void) {
        ImageCloudManager.fetchImages({images, error in
            if (nil == error && nil != images) {
                println("IMAGES")
                
                for image in images! {
                    println(image.description())
                }
                
                let assetIDs:[String] = (Image.MR_findAll() as NSArray).valueForKey("assetID") as [String]
                
                for image in images! {
                    //create coredata entity if it doesn't exist
                    if (!contains(assetIDs, image.identifier!)) {
                        var imagePersistanceObject:Image = Image.MR_createEntity() as Image
                        imagePersistanceObject.assetID = image.identifier!
                        
                        //CloudKit/filename
                        
                        let imagePath = image.imagePath!
                        
                        var stringRange:Range<String.Index> = Range(start:imagePath.startIndex, end: imagePath.endIndex)
                        let fileNameRange:Range = imagePath.rangeOfString("CloudKit", options: NSStringCompareOptions.CaseInsensitiveSearch, range: stringRange, locale: NSLocale.currentLocale())!

                        stringRange = Range(start: fileNameRange.startIndex, end: imagePath.endIndex)
                        imagePersistanceObject.fileName = imagePath.substringWithRange(stringRange)
                        
                        println("filename \(imagePersistanceObject.fileName)")

                        let author:Author? = Author.MR_findFirstByAttribute("serverID", withValue: image.ownerID!) as? Author
                        
                        if (nil != author) {
                            imagePersistanceObject.author = author!
                        }
                        
                        imagePersistanceObject.timestamp = image.date
                        imagePersistanceObject.latitude = image.location.coordinate.latitude
                        imagePersistanceObject.longitude = image.location.coordinate.longitude
                        self.locaLocationDescriptionIfNeededForLocation(imagePersistanceObject, location:image.location)
                    }
                }
                
                NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
                completionHandler(error: nil)
            } else {
                completionHandler(error: error)
            }
        })
    }
}