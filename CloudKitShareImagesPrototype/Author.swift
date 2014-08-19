//
//  Author.swift
//  CloudKitShareImagesPrototype
//
//  Created by alexbutenko on 7/7/14.
//  Copyright (c) 2014 SUSH Mobile. All rights reserved.
//

import Foundation
import CoreData

@objc(Author)
class Author : NSManagedObject {
    @NSManaged var name: String
    @NSManaged var serverID: String
    @NSManaged var images: NSSet
}
