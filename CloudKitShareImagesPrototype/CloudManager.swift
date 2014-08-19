//
//  CloudManager.swift
//  SimpleChat
//
//  Created by alexbutenko on 6/11/14.
//  Copyright (c) 2014 alexbutenko. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation

class CloudManager {
    
    struct ModelKeys {
        static let UserType = "User"
        static let Username = "UserName"
        static let UserID = "UserID"
        static let AssetType = "ImageAsset"
        static let AssetValue = "ImageAssetValue"
        static let AssetLocation = "ImageLocation"
        static let AssetAuthor = "ImageAuthor"
    }
    
    struct SingleInstance {
        static let sharedCloudManager: CloudManager = {
            let cloudManager = CloudManager()
            
            return cloudManager
            }()
    }
    
    class var sharedInstance: CloudManager {
        return SingleInstance.sharedCloudManager
    }
        
    var container: CKContainer {
        return CKContainer.defaultContainer()
    }
    
    var publicDatabase: CKDatabase {
        return container.publicCloudDatabase
    }
    
    func requestDiscoverabilityPermission(completionHandler: (Bool, NSError?) -> Void) {
        
//        println("container \(container)")
        
        container.statusForApplicationPermission(.PermissionUserDiscoverability, completionHandler: {status, error in
            
            if (error) {
                NSLog("statusForApplicationPermission error occured %@", error);
            }
            
            if (status == CKApplicationPermissionStatus.InitialState) {
                self.container.requestApplicationPermission(.PermissionUserDiscoverability, {
                    status, error in
                    if (error) {
                        NSLog("requestApplicationPermission error occured %@", error);
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {completionHandler(status == CKApplicationPermissionStatus.Granted, error)})
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {completionHandler(true, error)})
            }
        })        
    }
    
    func discoverUserInfo(completionHandler: (CKDiscoveredUserInfo!, NSError?) -> Void) {
        
        container.fetchUserRecordIDWithCompletionHandler({(recordId: CKRecordID!, error: NSError!) in
            if (error) {
                NSLog("fetchUserRecordIDWithCompletionHandler error occured %@", error)
                dispatch_async(dispatch_get_main_queue(), {completionHandler(nil, error)})

            } else {
                self.container.discoverUserInfoWithUserRecordID(recordId, {userInfo, error in
                        if (error) {
                            NSLog("discoverUserInfoWithUserRecordID error occured %@", error)
                        }
                        dispatch_async(dispatch_get_main_queue(), {completionHandler(userInfo, error)})
                    })
            }
            })
    }
  
    func uploadAssetWithURL(assetURL:NSURL, location:CLLocation, authorID:String, completionHandler:(record:CKRecord?, error:NSError?) -> Void) {
        var assetRecord = CKRecord(recordType: ModelKeys.AssetType)
        let asset = CKAsset(fileURL: assetURL)
        //no need to pass timestamp, because we can get creationDate of any record
        assetRecord.setObject(asset, forKey: ModelKeys.AssetValue)
        assetRecord.setObject(location, forKey: ModelKeys.AssetLocation)
        
        let authorRecordID = CKRecordID(recordName: authorID)
        let authorReference = CKReference(recordID: authorRecordID, action: .DeleteSelf)

        assetRecord.setObject(authorReference, forKey: ModelKeys.AssetAuthor)
        
        publicDatabase.saveRecord(assetRecord) {
            record, error in
            println("Error occured \(error)")
            
            dispatch_async(dispatch_get_main_queue(), {completionHandler(record: record, error:error)})
        }
    }

    func addUser(name: String, ID: String, completionHandler: (CKRecord) -> Void) {
        var record = CKRecord(recordType: ModelKeys.UserType)
        record.setObject(name, forKey: ModelKeys.Username)
        record.setObject(ID, forKey: ModelKeys.UserID)
        
        publicDatabase.saveRecord(record, {record, error in
            if (error) {
                NSLog("saveRecord error %@", error)
            } else {
                dispatch_async(dispatch_get_main_queue(), {completionHandler(record)})
            }
        })
    }
    
    func fetchRecordsOfType(type: String, completionHandler: ([CKRecord], NSError?) -> Void) {
        var records = [CKRecord]()
        
        let predicate = NSPredicate(value: true)
        var query = CKQuery(recordType: type, predicate: predicate)

        var queryOperation = CKQueryOperation(query: query)

        queryOperation.recordFetchedBlock = { record in
            records.append(record)
        }

        queryOperation.queryCompletionBlock = {_, error in
            if (error) {
                println(error)
            }

            dispatch_async(dispatch_get_main_queue(), {completionHandler(records, error)})
        }
        
        publicDatabase.addOperation(queryOperation)
    }
    
    func fetchRecordWithID(recordIDString: String, completionHandler: (CKRecord, NSError!) -> Void) {
        let recordID = CKRecordID(recordName: recordIDString)
        
        publicDatabase.fetchRecordWithID(recordID, {record, error in
            if (error) {
                println(error)
            }
            
            dispatch_async(dispatch_get_main_queue(), {completionHandler(record, error)})
        })
    }
    
    func fetchRecordWithID(recordIDString: String, recordType: String, completionHandler: (CKRecord?) -> Void) {
        fetchRecordsOfType(recordType) {records, error in
//            println("records \(records)")
            records.filter({record in
                return record.objectForKey(ModelKeys.UserID) as NSString == recordIDString
            })
            
            if (records.count > 0) {
                completionHandler(records[0])
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func fetchUserWithID(recordIDString: String, completionHandler: (CKRecord?) -> Void) {
        fetchRecordWithID(recordIDString, recordType: ModelKeys.UserType, completionHandler: completionHandler)
    }
    
    //TODO: implement fetching of all users
//    func fetchUsers(completionHandler: ([CKRecord]) -> Void) {
//        fetchRecordsOfType(ModelKeys.UserType, completionHandler: completionHandler)
//    }
    
    func fetchImages(completionHandler: ([CKRecord]?, NSError?) -> Void) {
        fetchRecordsOfType(ModelKeys.AssetType, completionHandler)
    }
}