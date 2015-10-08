//
//  CreateRoomVC.swift
//  NVBeta
//
//  Created by Dustin Jones on 10/8/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import UIKit

class CreateRoomVC: UIViewController {
    
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("CreateRoom_Home", sender: nil)
    }
    
    
}
