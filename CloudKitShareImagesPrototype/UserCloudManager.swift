//
//  UserDataManager.swift
//  CloudKitShareImagesPrototype
//
//  Created by alexbutenko on 7/4/14.
//  Copyright (c) 2014 SUSH Mobile. All rights reserved.
//

import Foundation
import CloudKit

class UserCloudManager {
    
    class func setupWithCompletionHandler(completionHandler:(User?, NSError?)->Void) {
        CloudManager.sharedInstance.requestDiscoverabilityPermission({discoverable, error in
            println("discoverable \(discoverable)")
            
            if (discoverable) {
                //TODO: could be better to validate if there are persisted values
                CloudManager.sharedInstance.discoverUserInfo(){userInfo, error in
                    
                    if (userInfo) {
//                        NSLog("firstname %@ lastname %@ ID %@", userInfo.firstName, userInfo.lastName, userInfo.userRecordID.recordName)
                        
                        CloudManager.sharedInstance.fetchUserWithID(userInfo.userRecordID.recordName) {
                            user in
//                            println("user \(user) userInfo \(userInfo)")
                            
                            //check how we can get all records of type users
                            if (nil == user) {
                                println("need to create \(userInfo.firstName)")
                                
                                CloudManager.sharedInstance.addUser(userInfo.firstName, ID:userInfo.userRecordID.recordName, {record in
                                        println("created \(userInfo.firstName)")
                                        completionHandler(User(userName:userInfo.firstName, userID:record.recordID.recordName), error)
                                    })
                            } else {
                                completionHandler(User(userName:userInfo.firstName, userID:user!.recordID.recordName), error)
                            }
                        }
                    } else {
                        completionHandler(nil, error)
                    }
                }
            } else if (nil != error) {
                completionHandler(nil, error)
            }
        })
    }

}