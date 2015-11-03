//
//  RoomFinder.swift
//  NVBeta
//
//  Created by Dustin Jones on 10/8/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import Foundation
import Parse

class RoomFinder {
    
    private var Rooms:[String] = []
    
    
    //Testing defaults
    
    /*Returns a default set of rooms for testing
     *Contains a completion handler that holds return until completion 
     *Eventually will return rooms with the */
    
    func findRooms(completion: (result: [String]) -> Void){
        
        let query = PFQuery(className: "RoomObjects")
        query.whereKey("roomID", equalTo: "")
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        let name = object.valueForKey("roomName") as! String
                        if !serverLink.Rooms.contains(name) {
                            serverLink.Rooms.append(name)
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            completion(result: serverLink.Rooms)
        }
    }
    
    /*Adds a room to list of Rooms*/
    func addRoom(roomName:String, priv:Bool) {
        let RoomObject = PFObject(className:"RoomObjects")
        RoomObject["roomName"] = roomName
        RoomObject["roomID"] = ""
        RoomObject["roomPrivate"] = priv
        RoomObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                
            } else {
                // There was a problem, check error.description
            }
        }
        
    }
    
    func removeRoom(roomName:String) {
        //no clue yet how to do this.
    }

}

