//
//  ViewController.swift
//  Spot_test
//
//  Created by uics15 on 9/22/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPTAuthViewDelegate, SPTAudioStreamingPlaybackDelegate {

    let kClientID = "ddf55f7bf8ec47e1a9a998c53207adb2"
    let kCallbackURL = "notevote-login://callback"
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshURL = "http://localhost:1234/refresh"

    
    var player: SPTAudioStreamingController?
    let spotifyAuthenticator = SPTAuth.defaultInstance()
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerLabel: UILabel!
    @IBAction func loginWithSpotify(sender: AnyObject) {

        spotifyAuthenticator.clientID = kClientID
        spotifyAuthenticator.requestedScopes = [SPTAuthStreamingScope]
        spotifyAuthenticator.redirectURL = NSURL(string: kCallbackURL)
        spotifyAuthenticator.tokenSwapURL = NSURL(string: kTokenSwapURL)
        spotifyAuthenticator.tokenRefreshURL = NSURL(string: kTokenRefreshURL)
        
        let spotifyAuthenticationViewController = SPTAuthViewController.authenticationViewController()
        spotifyAuthenticationViewController.delegate = self
        spotifyAuthenticationViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        spotifyAuthenticationViewController.definesPresentationContext = true
        presentViewController(spotifyAuthenticationViewController, animated: false, completion: nil)
    }
    
    @IBAction func registerButtonPressed(sender: UIButton) {
        //hyperlink to spotify register page and open in safari
    }
    
    // SPTAuthViewDelegate protocol methods
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        setupSpotifyPlayer()
        loginWithSpotifySession(session)
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("login cancelled")
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("login failed")
    }
    
    // SPTAudioStreamingPlaybackDelegate protocol methods
    
    private
    
    func setupSpotifyPlayer() {
        player = SPTAudioStreamingController(clientId: spotifyAuthenticator.clientID) // can also use kClientID; they're the same value
        player!.playbackDelegate = self
        player!.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
    }
    
    func loginWithSpotifySession(session: SPTSession) {
        player!.loginWithSession(session, callback: { (error: NSError!) in
            if error != nil {
                print("Couldn't login with session: \(error)")
                return
            }
            //TODO: cant put NSObject in NSUserDefaults. check SPTAuth?
            let userDefaults = NSUserDefaults.standardUserDefaults();
            let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
            userDefaults.setObject(sessionData, forKey: "session")
            userDefaults.synchronize()
            self.useLoggedInPermissions()
        })
    }
    
    func useLoggedInPermissions() {
        print("track is playing")
        let spotifyURI = "spotify:track:1WJk986df8mpqpktoktlce"
        player!.playURIs([NSURL(string: spotifyURI)!], withOptions: nil, callback: nil)
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sessionData = userDefaults.objectForKey("session")
        
        
        if(sessionData == nil) { return }
        
        let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData as! NSData) as! SPTSession
        
        if (session.isValid()) {
            setupSpotifyPlayer()
            loginWithSpotifySession(session)
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}

