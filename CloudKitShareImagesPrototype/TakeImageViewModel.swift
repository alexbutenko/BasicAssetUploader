//
//  TakeImageViewModel.swift
//  CloudKitShareImagesPrototype
//
//  Created by alexbutenko on 7/4/14.
//  Copyright (c) 2014 SUSH Mobile. All rights reserved.
//

import UIKit
import AssetsLibrary
import CoreLocation

class TakeImageViewModel : NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
 
    @IBOutlet var targetImageView: UIImageView?
    @IBOutlet var owner: UIViewController?
    var imageDataManager: ImageDataManager?
    var locationManager:CLLocationManager = CLLocationManager()
    var errorMessage:String = ""
    
    func showDialog() {
        
        var actionSheet = UIAlertController(title: "Take Photo", message: nil, preferredStyle:.ActionSheet)
        
        if (targetImageView!.image != nil) {
            actionSheet.addAction(UIAlertAction(title: "Delete photo", style: .Destructive) {_ in self.targetImageView!.image = nil})
        }
        
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            actionSheet.addAction(UIAlertAction(title: "Take photo", style: .Default) {_ in
                self.setupLocationManager()
                self.showPickerWithSourceType(.Camera)})
        }
        
        if (UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)) {
            actionSheet.addAction(UIAlertAction(title: "Choose existing", style: .Default) {_ in self.showPickerWithSourceType(.PhotoLibrary)})
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        owner!.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showErrorDialogIfNeeded() {
        if (errorMessage.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
            var alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
            owner!.presentViewController(alert, animated: true, completion: nil)
            
            errorMessage = ""
        }
    }
    
    func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        locationManager.startUpdatingLocation()
    }
    
    func showPickerWithSourceType(sourceType:UIImagePickerControllerSourceType) {
        var controller = UIImagePickerController()
        controller.modalPresentationStyle = .CurrentContext
        controller.sourceType = sourceType
        controller.delegate = self
        
        owner!.presentViewController(controller, animated: true, completion: nil)
    }
    
    // UIImagePickerDelegate
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        
        println("info \(info)")
        
        var image = info.valueForKey(UIImagePickerControllerOriginalImage) as UIImage
        
        if (info.valueForKey(UIImagePickerControllerReferenceURL)) {
            ALAssetsLibrary().assetForURL(info.valueForKey(UIImagePickerControllerReferenceURL) as NSURL, {asset in
                    if (asset) {
                        
                        if (!asset.valueForProperty(ALAssetPropertyLocation)) {
                            self.errorMessage = "No location specified for this photo. "
                        }
                        
                        
                        if (!asset.valueForProperty(ALAssetPropertyDate)) {
                            self.errorMessage += "No date specified for this photo."
                        }
                        
                        
                        if (self.errorMessage == "") {
                            println("asset location \(asset.valueForProperty(ALAssetPropertyLocation)) date \(asset.valueForProperty(ALAssetPropertyDate))")
                            
                            self.targetImageView!.image = image

                            self.imageDataManager = ImageDataManager(image: image, location: asset.valueForProperty(ALAssetPropertyLocation) as CLLocation, date: (asset.valueForProperty(ALAssetPropertyDate)) as NSDate)
                        }
                    }
                },
                {error in println("failed to get asset from library \(error)")})
        } else {
            self.imageDataManager = ImageDataManager(image: image, location: locationManager.location, date: NSDate.date())
            locationManager.stopUpdatingLocation()
        }
        
        picker.dismissViewControllerAnimated(true, completion: {self.showErrorDialogIfNeeded()})
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveImage() {
        if (nil != imageDataManager) {
            imageDataManager!.saveImage()
        }
    }
}