//
//  ActiveRoomVC.swift
//  NVBeta
//
//  Created by Dustin Jones on 10/8/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import UIKit

class ActiveRoom: UIViewController {

    @IBOutlet weak var navBarTitle: UILabel!
  
    @IBAction func exitButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("activeRoom_Home", sender: nil)
        
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let currentRoom = userDefaults.objectForKey("currentRoom") as! String
        navBarTitle.text = currentRoom
    }
}
