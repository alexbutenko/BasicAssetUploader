//
//  UserDataManager.swift
//  CloudKitShareImagesPrototype
//
//  Created by alexbutenko on 7/7/14.
//  Copyright (c) 2014 SUSH Mobile. All rights reserved.
//

import Foundation
import CoreData

class UserDataManager {
    
    struct SingleInstance {
        static let sharedUserDataManager: UserDataManager = {
            let userDataManager = UserDataManager()
            
            return userDataManager
        }()
    }
    
    class var sharedInstance: UserDataManager {
        return SingleInstance.sharedUserDataManager
    }
    
    var user:User!
    var persistedUser:Author?
    
    func setupWithUser(user:User) {
        //check persisted current user
        self.user = user
        
        persistedUser = Author.MR_findFirstByAttribute("serverID", withValue: user.userID) as? Author
        
        if (nil == persistedUser) {
            
            println("persisting user \(user.userName) \(user.userID)")
            persistedUser = Author.MR_createEntity() as? Author
            persistedUser!.name = user.userName
            persistedUser!.serverID = user.userID
            
            NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
        }
    }
}