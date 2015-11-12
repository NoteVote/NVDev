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
            
            /*SPTRequest.requestItemAtURI(NSURL(string: "spotify:album:4L1HDyfdGIkACuygktO7T7"), withSession: sessionObj, callback: { (error:NSError!, albumObj:AnyObject!) -> Void in
            if error != nil {
            println("Album lookup got error \(error)")
            return
            }
            
            let album = albumObj as SPTAlbum
            
            self.player?.playTrackProvider(album, callback: nil)
            })*/
            
            SPTRequest.performSearchWithQuery("let it go", queryType: SPTSearchQueryType.QueryTypeTrack, offset: 0, session: nil, callback: { (error:NSError!, result:AnyObject!) -> Void in
                let trackListPage = result as! SPTListPage
                
                let partialTrack = trackListPage.items.first as! SPTPartialTrack
                
                SPTRequest.requestItemFromPartialObject(partialTrack, withSession: nil, callback: { (error:NSError!, results:AnyObject!) -> Void in
                    let track = results as! SPTTrack
                    self.player?.playTrackProvider(track, callback: nil)
                })
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sessionHandler = SessionHandler()
        let session = sessionHandler.getSession()
        playUsingSession(session)
    }
}
