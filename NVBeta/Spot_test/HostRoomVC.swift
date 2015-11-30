//
//  HostRoomVC.swift
//  NVBeta
//
//  Created by uics15 on 11/5/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import UIKit
import Parse

class HostRoomVC: UIViewController, SPTAudioStreamingPlaybackDelegate {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var navBarTitle: UILabel!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    //TODO: Make songQueue a list of Dictionaries. Each dictionary has title, artist, and votes as keys.
    var musicList:[[AnyObject]] = []
    var roomID = ""
    
    private var player:SPTAudioStreamingController?
    private let authController = SpotifyAuth()
    
    func playUsingSession(sessionObj:SPTSession!){
        
        let kClientID = authController.getClientID()
        
        if player == nil {
            player = SPTAudioStreamingController(clientId: kClientID)
            player?.playbackDelegate = self
        }
        
        player?.loginWithSession(sessionObj, callback: { (error:NSError!) -> Void in
            if error != nil {
                print("Enabling playback got error \(error)")
                return
            }
            
            
            //TODO dynamic track URI
            
            
            self.player?.playURI(NSURL(string: "spotify:track:5pY3ovFxbvAg7reGZjJQSp"), callback: { (error:NSError!) -> Void in
                if error != nil {
                    print("Track lookup got error \(error)")
                    return
                }
                
            })
        })
    }
    
    //SPTAudioStreamingPlaybackDelegate methods

    
    //fires whenever the track changes
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        
        let albumURI = trackMetadata["SPTAudioStreamingMetadataAlbumURI"] as! String
        trackTitle.text! = trackMetadata["SPTAudioStreamingMetadataTrackName"] as! String
        trackArtist.text! = trackMetadata["SPTAudioStreamingMetadataArtistName"] as! String
        
        SPTAlbum.albumWithURI(NSURL(string: albumURI), session: nil) { (error:NSError!, albumObj:AnyObject!) -> Void in
            let album = albumObj as! SPTAlbum
            
            
            //TODO: I dont understand this dispatch async thing
            
            if let imgURL = album.largestCover.imageURL as NSURL! {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    var error:NSError? = nil
                    var coverImage = UIImage()
                    
                   if let imageData = NSData(contentsOfURL: imgURL){
                        
                        if error == nil {
                            coverImage = UIImage(data: imageData)!
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.albumImage.image = coverImage
                    })
                })
            }
            
        }

    }
    
    //fires when track stops playing
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: NSURL!) {
        let roomID = userDefaults.objectForKey("roomID") as! String
        serverLink.queueForRoomID(roomID){
            (result: [[AnyObject]]) in print(result)
            
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let currentRoom = userDefaults.objectForKey("currentRoom") as! String
        navBarTitle.text = currentRoom
        roomID = userDefaults.objectForKey("roomID") as! String
        serverLink.queueForRoomID(roomID){
            (result: [[AnyObject]]) in print(result)
            self.musicList = result
            
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sessionHandler = SessionHandler()
        let session = sessionHandler.getSession()
        playUsingSession(session)
    }
}
