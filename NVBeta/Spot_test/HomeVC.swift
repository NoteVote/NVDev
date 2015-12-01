//
//  HomeVC.swift
//  NVBeta
//
//  Created by uics15 on 9/29/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import UIKit
import Parse

class HomeVC: UIViewController, ENSideMenuDelegate, UITableViewDataSource, UITableViewDelegate{
    
    var roomsNearby:[String] = []
    var currentRoomID:String = ""
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    
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
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("Home_CreateRoom", sender: nil)
    }
    
    
    //Table View Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /*Number of rows of tableView*/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomsNearby.count
        //TODO: needs to return the number of rooms in the area.
    }
    
    /*CurrentPlayer Selected and moves to next page*/
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentRoom = roomsNearby[indexPath.row]
        serverLink.roomID(currentRoom){
            (result: String) in print(result)
            userDefaults.setObject(result, forKey: "roomID")
            
            //takes name of current room and saves it.
            userDefaults.setObject(currentRoom, forKey: "currentRoom")
            userDefaults.synchronize()
            //Will see if the room has been entered before or if it is new.
            serverLink.newRoomCheck()
            self.performSegueWithIdentifier("Home_ActiveRoom", sender: nil)
        }
    }
    
    /*Creating tableview cells*/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.textColor = UIColor(red: 125/255, green: 205/255, blue: 3/255, alpha: 1.0)
        cell.textLabel?.text = roomsNearby[indexPath.row]
        cell.textLabel?.font = UIFont.systemFontOfSize(30)
        //TODO: set cell atributes.
        return cell
    }
    
    
    // _____ Default View Controller Methods _____
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        //Handles result from completion handler.
        serverLink.findRooms(){
            (result: [String]) in
            self.roomsNearby = result
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
