//
//  HostRoomVC.swift
//  NVBeta
//
//  Created by uics15 on 11/5/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import UIKit
import Parse

class HostRoomVC: UIViewController, SPTAudioStreamingPlaybackDelegate, ENSideMenuDelegate {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var navBarTitle: UILabel!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    //TODO: Make songQueue a list of Dictionaries. Each dictionary has title, artist, and votes as keys.
    
    private var player:SPTAudioStreamingController?
    private let authController = SpotifyAuth()
    
    @IBAction func SearchButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("Host_Search", sender: nil)
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("sideMenuShouldOpenSideMenu")
        return true
    }
    
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        toggleSideMenuView()
    }
    
    @IBAction func playPausePressed(sender: AnyObject) {
        if (self.player!.isPlaying) {
            
            self.player!.setIsPlaying(false, callback: { (error:NSError!) -> Void in
                if error != nil {
                    print("Enabling playback got error \(error)")
                    return
                }
            })
            playPauseButton.setTitle("Play", forState: UIControlState.Normal)
            
        } else {
            
            self.player!.setIsPlaying(true, callback: { (error:NSError!) -> Void in
                if error != nil {
                    print("Enabling playback got error \(error)")
                    return
                }
            })
            playPauseButton.setTitle("Pause", forState: UIControlState.Normal)
        }
    }
    
    
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
            
            if !serverLink.musicList.isEmpty {
                //TODO dynamic track URI
                let currentTrack = serverLink.musicList[0][0] as! String
                //serverLink.pop()
                print(currentTrack)
                self.player?.playURI(NSURL(string: currentTrack), callback: { (error:NSError!) -> Void in
                    if error != nil {
                        print("Track lookup got error \(error)")
                        return
                    }
                    
                })
            }
        })
    }
    
    //SPTAudioStreamingPlaybackDelegate methods

    
    //fires whenever the track changes
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if trackMetadata == nil {
            
            //TODO: SELECT SONGS ON VOTES, SOMEHOW IMPLEMENT PLAYLIST INTEGRATION
            if (!serverLink.musicList.isEmpty) {
                let currentTrack = serverLink.musicList[0][0] as! String
                serverLink.musicList.removeAtIndex(0)
                print(currentTrack)
                self.player?.playURI(NSURL(string: currentTrack), callback: { (error:NSError!) -> Void in
                    if error != nil {
                        print("Track lookup got error \(error)")
                        return
                    }
                })
            }
        } else {
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

    }
    func startSession(){
        let sessionHandler = SessionHandler()
        let session = sessionHandler.getSession()
        playUsingSession(session)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let currentRoom = userDefaults.objectForKey("currentRoom") as! String
        navBarTitle.text = currentRoom
//        startSession()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let view:String = "Host"
        let destinationVC = segue.destinationViewController as! SearchVC
        destinationVC.preView = view
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !serverLink.musicList.isEmpty {
            startSession()
        }
    }
}
