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
    
    //Needed for HostVC Refresh
    var albumArt:UIImage?
    var trackTitle:String?
    var artistName:String?
    
    private var Rooms:[(String,String)] = []
    var songsVoted:[String:[String]] = [:]
    var musicList:[[AnyObject]] = []
    var musicOptions:[[AnyObject]] = []
    var searchList:[SPTPartialTrack] = []
    
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
			
			PFAnalytics.trackEventInBackground("getrooms", block: nil)
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
			
			PFAnalytics.trackEventInBackground("createroom", block: nil)
            if (success) {
                // The object has been saved.
                
            } else {
                // There was a problem, check error.description
            }
        }
        
    }
    
	
    func pop() ->String {
        let roomID = userDefaults.objectForKey("roomID") as! String
        
//        syncQueueForRoomID(roomID)
//        PFAnalytics.trackEventInBackground("getqueue", dimensions: ["where":"host"], block: nil)
		
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
		PFAnalytics.trackEventInBackground("savequeue", dimensions: ["where":"host"], block: nil)
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
		PFAnalytics.trackEventInBackground("vote", dimensions: ["type":"up"], block: nil)
        for i in 0...serverLink.musicList.count-1 {
            if songURI == serverLink.musicList[i][0] as! String {
                serverLink.musicList[i][3] = (serverLink.musicList[i][3] as! Int) + 1
                serverLink.songsVoted[userDefaults.objectForKey("roomID") as! String]?.append(songURI)
                return
            }
        }
    }
    
    func incrementSongDown(songURI: String) {
		PFAnalytics.trackEventInBackground("vote", dimensions: ["type":"down"], block: nil)
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
    
    func setMusicOptions(){
        self.musicOptions = []
        var Song:[AnyObject] = ["","","",0]
        //var artistName:String!
        //var suportArtists:[String] = []
        for track in self.searchList {
            Song[0] = String(track.uri)
            Song[1] = track.name
            let str = String(track.artists.first)
            
            //Building artist name with parsing.
            let strList = str.componentsSeparatedByString(" ")
            var artistName:String = strList[2]
            if(strList.count-1 > 3){
                for i in 3...strList.count-2{
                    artistName += " " + strList[i]
                }
            }

            Song[2] = artistName
            self.musicOptions.append(Song)
        }
        print(self.musicOptions)
    }
	
	//TODO: ENSURE THIS DOES NOT OVERWRITE QUEUE
    func addSongToQueue(song:[AnyObject]){
        let roomID = userDefaults.objectForKey("roomID") as! String
        syncQueueForRoomID(roomID)
        PFAnalytics.trackEventInBackground("getqueue", dimensions: ["where":"search"], block: nil)
        self.musicList.append(song)
        self.songsVoted[roomID]?.append(song[0] as! String)
        self.saveRoomQueue(roomID)
		PFAnalytics.trackEventInBackground("savequeue", dimensions: ["where":"search"], block: nil)
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
			
			PFAnalytics.trackEventInBackground("deleteroom", block: nil)
            for object in objects! {
                object.deleteInBackground()
            }
        }
    }
}

