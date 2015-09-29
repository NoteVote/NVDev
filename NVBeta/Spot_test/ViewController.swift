//
//  ViewController.swift
//  
//  This class is a view controller for the login screen and handles user login.
//
//  Created by Aaron Kaplan on 9/22/15.
//  Copyright © 2015 NoteVote. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SPTAuthViewDelegate {

    // _____ Declarations _____
    
    private let sessionHandler = SessionHandler()
    private let authController = SpotifyAuth()
    private let spotifyAuthenticator = SPTAuth.defaultInstance()
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerLabel: UILabel!
    
    
    // _____ SPTAuthViewDelegate Methods _____
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("Login Successful")
        storeSession(session)
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("login cancelled")
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("login failed")
    }
    
    
    // _____ GUI Actions _____
    
    @IBAction func loginWithSpotify(sender: AnyObject) {
        
        authController.setParameters(spotifyAuthenticator)
        
        let spotifyAuthenticationViewController = SPTAuthViewController.authenticationViewController()
        spotifyAuthenticationViewController.delegate = self
        spotifyAuthenticationViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        spotifyAuthenticationViewController.definesPresentationContext = true
        presentViewController(spotifyAuthenticationViewController, animated: false, completion: nil)
    }

    @IBAction func registerButtonPressed(sender: UIButton) {
        //hyperlink to spotify register page and open in safari
        print("register pressed")
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.spotify.com")!)
    }
    
    
    // _____ Additional Methods _____
    
    func storeSession(session: SPTSession) {
        
        sessionHandler.storeSession(session)
        
    }


    // _____ Default View Controller Methods _____
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let session = sessionHandler.getSession()
        
        if (session != nil) {
            if (session!.isValid()) {
                print("session is valid")
            } else {
                print("reauthorize")
            }
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}

