//
//  CreateRoomVC.swift
//  NVBeta
//
//  Created by Dustin Jones on 10/8/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import UIKit
import Parse

class CreateRoomVC: UIViewController {
    
    let sessionHandler = SessionHandler()
    var session:SPTSession? = nil
    @IBOutlet weak var roomName: UITextField!
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("CreateRoom_Home", sender: nil)
        //TODO: why is this here? useless server request?
        //serverLink.removeRoom("hello")
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        serverLink.addRoom(roomName.text!, id: session!.canonicalUsername, priv: false)
        serverLink.roomID(roomName.text!){
            (result: String) in print(result)
            userDefaults.setObject(self.roomName.text!, forKey: "currentRoom")
            userDefaults.setObject(result, forKey: "roomID")
            userDefaults.synchronize()
            self.performSegueWithIdentifier("CreateRoom_HostRoom", sender: nil)
        }
    }
    
    func setCurrentSession(session: SPTSession) {
        self.session = session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sessionHandler = SessionHandler()
        let session = sessionHandler.getSession()
        setCurrentSession(session!)
    }

    
    
}
