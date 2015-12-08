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
    
    private var Rooms:[(String,String)] = []
    var songsVoted:[String:[String]] = [:]
    var musicList:[[AnyObject]] = []
    var musicOptions:[[AnyObject]] = []
    
    
    //Testing defaults
    
    /*Returns a default set of rooms for testing
     *Contains a completion handler that holds return until completion 
     *Eventually will return rooms with the */
    
    func findRooms(completion: (result: [(String,String)]) -> Void){
        self.Rooms = []
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
                        let roomID:String = object.valueForKey("roomID") as! String
                        let roomName:String = object.valueForKey("roomName") as! String
                        serverLink.Rooms.append((roomName,roomID))
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
        
            completion(result: roomID)
        }
    }
    func pop() ->String {
        let roomID = userDefaults.objectForKey("roomID") as! String
        
        syncQueueForRoomID(roomID)
        
        var highest:(Int,Int) = (0,0)
        for i in 0...musicList.count-1 {
            let voteCount = musicList[i][3] as! Int
            if(voteCount > highest.0){
                highest.0 = voteCount
                highest.1 = i
            }
        }
        let uri = musicList[highest.1][0] as! String
        print("sync worked")
        self.musicList.removeAtIndex(highest.1)
        saveRoomQueue(roomID)
        return uri
    }
    
    
    func syncQueueForRoomID(roomID:String){
        let query = PFQuery(className: "RoomObjects")
        query.whereKey("roomID", equalTo: roomID)
        
        do {
            let objects = try query.findObjects()
            let room = objects[0]
            let queue = room.objectForKey("queue")
            if queue != nil {
                serverLink.musicList = queue as! [[AnyObject]]
            }
        } catch {
            print("there was an error updating music list (sync)")
        }

    }

    
    func saveRoomQueue(roomID:String) {
        let query = PFQuery(className: "RoomObjects")
        query.whereKey("roomID", equalTo: roomID)
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error: NSError?) -> Void in
            if(error == nil) {
                let Object = objects![0]
                Object.setObject(self.musicList, forKey: "queue")
                Object.saveInBackground()
                
            } else {
                print("Error: no room with id: " + roomID)
            }
        }
    }
    
    func incrementSongUp(songURI: String) {
        for i in 0...serverLink.musicList.count-1 {
            if songURI == serverLink.musicList[i][0] as! String {
                serverLink.musicList[i][3] = (serverLink.musicList[i][3] as! Int) + 1
                serverLink.songsVoted[userDefaults.objectForKey("roomID") as! String]?.append(songURI)
                return
            }
        }
    }
    
    func incrementSongDown(songURI: String) {
        for i in 0...musicList.count-1 {
            if songURI == musicList[i][0] as! String {
                serverLink.musicList[i][3] = (serverLink.musicList[i][3] as! Int) - 1
                //Finds index of song and
                let index:Int = serverLink.songsVoted[userDefaults.objectForKey("roomID") as! String]!.indexOf(songURI)!
                serverLink.songsVoted[userDefaults.objectForKey("roomID") as! String]!.removeAtIndex(index)
                return
            }
        }
    }
    
    func getSongOptions(completion: (result: String) -> Void){
        let query = PFQuery(className: "SongLibrary")
        query.whereKey("trackTitle", notEqualTo: "")
        self.musicOptions = []
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    var song:[AnyObject] = []
                    var inList = false
                    let testUri = object.objectForKey("uri") as! String
                    for Track in self.musicList {
                        if(Track[0] as! String == testUri){
                            inList = true
                        }
                    }
                    if(!inList){
                        song.append(object.objectForKey("uri") as! String)
                        song.append(object.objectForKey("trackTitle") as! String)
                        song.append(object.objectForKey("trackArtist") as! String)
                        song.append(0)
                        self.musicOptions.append(song)
                    }
                }
            } else {
                print("song options missing")
            }
            completion(result: "Done")
        }
    }
    
    func addSongToQueue(songURI:String){
        for song in self.musicOptions{
            if( songURI == (song[0] as! String)){
                self.musicList.append(song)
                self.saveRoomQueue(userDefaults.objectForKey("roomID") as! String)
                
                return
            }
        }
    }
    
    func songsVotedCheck(){
        if(!songsVoted.keys.contains(userDefaults.objectForKey("roomID") as! String)){
            songsVoted[(userDefaults.objectForKey("roomID") as! String)] = []
        }
    }
    
    
    func queueForRoomID(roomID:String, completion: (result: [[AnyObject]]) -> Void){
        var musicList:[[AnyObject]] = []
        let query = PFQuery(className: "RoomObjects")
        query.whereKey("roomID", equalTo: roomID)
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                let room = objects![0]
                let queue = room.objectForKey("queue")
                if queue != nil {
                    musicList = queue as! [[AnyObject]]
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            completion(result: musicList)
        }
    }
    
    func deleteRoom(roomID: String) {
        let roomID = userDefaults.objectForKey("roomID") as! String
        let query = PFQuery(className: "RoomObjects")
        query.whereKey("roomID", equalTo: roomID)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            for object in objects! {
                object.deleteEventually()
            }
        }
    }
}

