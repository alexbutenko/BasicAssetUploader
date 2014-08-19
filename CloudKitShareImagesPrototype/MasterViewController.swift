//
//  MasterViewController.swift
//  CloudKitShareImagesPrototype
//
//  Created by alexbutenko on 7/3/14.
//  Copyright (c) 2014 SUSH Mobile. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil

    @IBOutlet var syncManager: SyncManager?
    @IBOutlet var listViewModel: ImageListViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        
        listViewModel!.onDidSelectRowWith = {item in
            self.detailViewController!.detailItem = item
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "onTakeImage:")
        
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.endIndex-1].topViewController as? DetailViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onTakeImage(sender:UIBarButtonItem) {
        performSegueWithIdentifier("TakeImageSegue", sender: sender)
    }

    // #pragma mark - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            ((segue.destinationViewController as UINavigationController).topViewController as DetailViewController).detailItem = listViewModel!.selectedObject
        }
    }
}

