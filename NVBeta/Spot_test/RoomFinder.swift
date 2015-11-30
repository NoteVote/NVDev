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
        //NEED TO FIX THIS BEFORE RELEASEING
        query.whereKey("roomID", notEqualTo: "0")
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
    func addRoom(roomName:String, id: String, priv:Bool) {
        let RoomObject = PFObject(className:"RoomObjects")
        RoomObject["roomName"] = roomName
        RoomObject["roomID"] = id
        RoomObject["roomPrivate"] = priv
        RoomObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                
            } else {
                // There was a problem, check error.description
                print("WE FAILED")
            }
        }
        
    }
    /*query used to find roomID from roomName*/
    func roomID(roomName:String, completion: (result: String) -> Void){
        var roomID:String = ""
        let query = PFQuery(className: "RoomObjects")
        query.whereKey("roomName", equalTo: roomName)
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                let room = objects![0]
                roomID = room.objectForKey("roomID") as! String
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        completion(result: roomID)
    }
    
    func queueForRoomID(roomID:String, completion: (result: [[AnyObject]]) -> Void){
        var musicList:[[AnyObject]] = [[]]
        let query = PFQuery(className: "RoomObjects")
        query.whereKey("roomPin", equalTo: "tester")
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                let room = objects![0]
                musicList = room.objectForKey("queue") as! [[AnyObject]]
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            completion(result: musicList)
        }
    }
    
    func removeRoom(roomName:String) {
        //no clue yet how to do this.
    }

}

