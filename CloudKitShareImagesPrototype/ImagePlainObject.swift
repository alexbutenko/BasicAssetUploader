//
//  ImagePlainObject.swift
//  CloudKitShareImagesPrototype
//
//  Created by alexbutenko on 7/7/14.
//  Copyright (c) 2014 SUSH Mobile. All rights reserved.
//

import Foundation
import CoreLocation

class ImagePlainObject {
    var image:UIImage?
    var location:CLLocation
    var date:NSDate
    var ownerID:String?
    var imagePath:String?
    var identifier:String?
    
    init (image:UIImage, location:CLLocation, date:NSDate) {
        self.image = image
        self.location = location
        self.date = date
    }
    
    init (imagePath:String, location:CLLocation, date:NSDate, ownerID:String, identifier:String) {
        self.imagePath = imagePath
        self.location = location
        self.date = date
        self.ownerID = ownerID
        self.identifier = identifier
    }
    
    func description() -> String {
        return "ID: " + identifier! + " path: " + imagePath!
    }
}