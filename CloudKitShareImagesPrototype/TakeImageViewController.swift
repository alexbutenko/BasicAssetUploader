//
//  TakeImageViewController.swift
//  CloudKitShareImagesPrototype
//
//  Created by alexbutenko on 7/4/14.
//  Copyright (c) 2014 SUSH Mobile. All rights reserved.
//

import UIKit

class TakeImageViewController: UIViewController {
 
    @IBOutlet var takeImageViewModel: TakeImageViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        dispatch_after(1, dispatch_get_main_queue(), {self.takeImageViewModel!.showDialog()})
    }
    
    @IBAction func onDone(sender: UIBarButtonItem) {
        takeImageViewModel!.saveImage()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onTakeImage(sender: UIBarButtonItem) {
        takeImageViewModel!.showDialog()
    }
}
