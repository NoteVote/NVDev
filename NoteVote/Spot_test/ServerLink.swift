//
//  ServerLink.swift
//  NoteVote
//
//  Created by Dustin Jones on 12/21/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import Foundation
import Parse

class ServerLink {
    
    //Needed for HostVC Refresh
    var albumArt:UIImage?
    var trackTitle:String?
    var artistName:String?
    var currentURI:String?
    
    private var rooms:[PFObject] = []
    private var partyObject:PFObject!
    var songsVoted:[String:[PFObject]] = [:]
    var musicOptions:[Song] = []
    var musicList:[PFObject] = []
    var searchList:[SPTPartialTrack] = []
    
    
    //- - - - - Internal Methods - - - - -
    
    /**
    * Finds rooms based on a geolocation point of the current device.
    * Will append results to rooms variable -- as a list of PFObjects.
    */
    func findRooms(completion: (result: [PFObject]) -> Void){
        self.rooms = []
        let query = PFQuery(className: "PartyObject")
        
        // NEED TO FIX THIS BEFORE RELEASEING
        // will search within certain distance to phone's location.
        query.whereKey("partyID", notEqualTo: "0")
        query.findObjectsInBackgroundWithBlock{
            (objects: [PFObject]?, error: NSError?) -> Void in
            PFAnalytics.trackEventInBackground("getrooms", block: nil)
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        serverLink.rooms.append(object)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            completion(result: serverLink.rooms)
        }
    }
    /**
     * Sets the current room to the room selected by the user.
     * -takes in an Int(objectNum) -> used to locate correct room from rooms variable.
     */
    func partySelect(objectNum:Int){
        partyObject = rooms[objectNum]
    }
    
    /**
     * Adds a party object to the Parse PartyObject class.
     * -takes in a String(partyName) -> used to set the parties name.
     * -takes in a String(partyID) -> used to set the partiesID to the hosts Spotify ID.
     * -takes in a Bool(priv) -> used to set the room as private or not.
     */
    func addParty(partyName:String, partyID:String, priv:Bool) {
        let partyObject = PFObject(className:"PartyObject")
        partyObject["partyName"] = partyName
        partyObject["partyID"] = partyID
        partyObject["partyPrivate"] = priv
        partyObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            
            PFAnalytics.trackEventInBackground("createroom", block: nil)
            if (success) {
                // The object has been saved.
                
            } else {
                // There was a problem, check error.description
            }
        }
    }
    
    /**
     * deletes a party object from the Parse PartyObject class.
     * -takes in a String(roomID) -> hosts Spotify ID, used to find correct object for deletion.
     */
    func deleteRoom(roomID: String) {
        let query = PFQuery(className: "PartyObject")
        query.whereKey("partyID", equalTo: partyObject.objectForKey("partyID") as! String)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            PFAnalytics.trackEventInBackground("deleteroom", block: nil)
            for object in objects! {
                object.deleteInBackground()
            }
        }
    }
    
    /**
     * Adds a song to the parties subclass of SongLibrary.
     * -takes in a String(trackTitle) -> title of the song.
     * -takes in a String(trackArtist) -> artist of the song.
     * -takes in a String(uri) -> Spotify track URI of the song.
     * uses these variables to create a song object in Parse.
     */
    func addSong(trackTitle:String, trackArtist:String, uri:String){
        let trackObject = PFObject(className: "SongLibrary")
        trackObject["trackTitle"] = trackTitle
        trackObject["trackArtist"] = trackArtist
        trackObject["uri"] = uri
        let relation:PFRelation = partyObject.relationForKey("queue")
        relation.addObject(trackObject)
    }
    
    /**
     * increments the vote on a specific song by 1.
     * -takes in a String(songURI) -> the Spotify track URI for the song voted on.
     * uses that to find the correct song.
     */
    func increment(songURI:String){
        let relation:PFRelation = partyObject.relationForKey("queue")
        let query:PFQuery? = relation.query()?.whereKey("uri", equalTo: songURI)
        if(query != nil){
            query?.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if(error == nil){
                    objects![0].incrementKey("votes")
                }
            }
        }
    }
    
    /**
     * decrements the vote on a specific song by 1.
     * -takes in a String(songURI) -> the Spotify track URI for the song voted on.
     * uses that to find the correct song.
     */
    func decrement(songURI:String){
        let relation:PFRelation = partyObject.relationForKey("queue")
        let query:PFQuery? = relation.query()?.whereKey("uri", equalTo: songURI)
        if(query != nil){
            query?.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if(error == nil){
                    objects![0].incrementKey("votes", byAmount: -1)
                }
            }
        }
    }
    
    /**
     * pops the top item off of musicList, Which should be the highest voted song.
     * then calls removeSong passing along the top song. while removing it form itself.
     * then returns the removed song's URI.
     */
    func pop()->String{
        sortMusicList()
        let uri:String = musicList.first!.objectForKey("uri") as! String
        serverLink.removeSong(musicList.first!)
        musicList.removeFirst()
        PFAnalytics.trackEventInBackground("savequeue", dimensions: ["where":"host"], block: nil)
        return uri
    }
    
    func removeSong(topSong:PFObject){
        let relation:PFRelation = partyObject.relationForKey("queue")
        relation.removeObject(topSong)
    }
    
    func syncGetQueue(){
        do {
            let relation = partyObject.relationForKey("queue")
            let query:PFQuery = relation.query()!
            let objects:[PFObject] = try query.findObjects()
            musicList = objects
        }
        catch {
            
        }
        
    }
    
    func getQueue(){
        do {
            let relation = partyObject.relationForKey("queue")
            relation.query()!.findObjectsInBackgroundWithBlock{
                (objects:[PFObject]?, error:NSError?) -> Void in
                if(error == nil && objects != nil){
                    serverLink.musicList = objects!
                }
            }
        }
    }
    
    
    func sortMusicList(){
        var temp:[PFObject] = []
        for object in musicList {
            if(temp.isEmpty){
                temp.append(object)
            }
            else{
                var index = 0
                for obj in temp {
                    let num1 = object.objectForKey("votes") as! Int
                    let num2 = obj.objectForKey("votes") as! Int
                    if(num1 > num2){
                        temp.insert(object, atIndex: index)
                        break
                    }
                    index+=1
                }
            }
        }
        musicList = temp
    }
    
    func setMusicOptions(){
        self.musicOptions = []
        for track in self.searchList {
            let song:Song = Song()
            song.setURI(String(track.uri))
            song.setTitle(track.name)
            let str = String(track.artists.first)
            
            //Building artist name with parsing.
            let strList = str.componentsSeparatedByString(" ")
            var artistName:String = strList[2]
            if(strList.count-1 > 3){
                for i in 3...strList.count-2{
                    artistName += " " + strList[i]
                }
            }
            song.setArtist(artistName)
            self.musicOptions.append(song)
        }
    }
}