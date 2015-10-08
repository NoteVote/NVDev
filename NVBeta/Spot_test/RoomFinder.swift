//
//  RoomFinder.swift
//  NVBeta
//
//  Created by Dustin Jones on 10/8/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import Foundation

class RoomFinder {
    
    private var Rooms:[String] = ["Dustin's Party","Aaron's Party","Alex's Party","Jessica's Party"]
    
    
    //Testing defaults
    
    /*Returns a default set of rooms for testing*/
    func findRooms() -> [String]{
        return Rooms
    }
    
    /*Adds a room to list of Rooms*/
    func addRoom(roomName:String) {
        Rooms.append(roomName)
    }
    
    func removeRoom(roomName:String) {
        let index:Int = Rooms.indexOf(roomName)!
        Rooms.removeAtIndex(index)
    }

}

