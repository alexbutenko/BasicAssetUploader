//
//  Configurator.swift
//  CloudKitShareImagesPrototype
//
//  Created by alexbutenko on 7/4/14.
//  Copyright (c) 2014 SUSH Mobile. All rights reserved.
//

import Foundation

class SyncManager : NSObject {
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        MagicalRecord.setupCoreDataStack()
        UserCloudManager.setupWithCompletionHandler(){ userObject, error in
            
            if (nil != userObject) {
                println("USER \n\(userObject!.userName) \(userObject!.userID)")
                
                //persist user object
                UserDataManager.sharedInstance.setupWithUser(userObject!)
                //TODO: retrieve all users from server
                
                ImageDataManager().fetchImages({error in
                    if (nil != error) {
                        var alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                        UIApplication.sharedApplication().keyWindow.rootViewController.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        println("IMAGES FETCHED SUCCESSFULLY!")
                    }
                })
            } else {
                println("error \(error)")
                
                //persist test user
                UserDataManager.sharedInstance.setupWithUser(User(userName:"test", userID:"123"))

                ImageDataManager().fetchImages({error in
                    if (nil != error) {
                        var alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                        UIApplication.sharedApplication().keyWindow.rootViewController.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        println("IMAGES FETCHED SUCCESSFULLY!")
                    }
                    })
                
                var alert = UIAlertController(title: "Error", message: "Check that you're logged in iCloud", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                UIApplication.sharedApplication().keyWindow.rootViewController.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}