//
//  ActiveRoomVC.swift
//  NVBeta
//
//  Created by Dustin Jones on 10/8/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import UIKit
import Parse

class ActiveRoomVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navBarTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //TODO: Make songQueue a list of Dictionaries. Each dictionary has title, artist, and votes as keys.
    var roomID = ""

    @IBAction func searchButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("ActiveRoom_Search", sender: nil)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    //Table View Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /*Number of rows of tableView*/
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverLink.musicList.count
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    /*Creating tableview cells*/
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("songCell", forIndexPath: indexPath) as! QueueTableCell
        if(!serverLink.musicList.isEmpty){
            if(!serverLink.newRoom ){
                if(serverLink.songsVoted[(userDefaults.objectForKey("roomID") as! String)]!.contains(serverLink.musicList[indexPath.row][0] as! String )){
                    cell.alreadyVoted()
                }
            }
            cell.songURI = serverLink.musicList[indexPath.row][0] as! String
            cell.songTitle.text! = serverLink.musicList[indexPath.row][1] as! String
            cell.artistLabel.text! = serverLink.musicList[indexPath.row][2] as! String
            let voteNum:String = String(serverLink.musicList[indexPath.row][3] as! Int)
            cell.voteButton.setTitle(voteNum, forState: UIControlState.Normal)
        }
        
        //TODO: somehow link to prototype cell QueueTableCell.swift
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

  
    @IBAction func exitButtonPressed(sender: UIBarButtonItem) {
        //TODO: remember votes and remove user from room on server
        performSegueWithIdentifier("activeRoom_Home", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue == "ActiveRoom_Search"){
            let view:String = "ActiveRoom"
            let destinationVC = segue.destinationViewController as! SearchVC
            destinationVC.preView = view
        }
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let currentRoom = userDefaults.objectForKey("currentRoom") as! String
        navBarTitle.text = currentRoom
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.tableView.separatorColor = UIColor.lightGrayColor()
        roomID = userDefaults.objectForKey("roomID") as! String
        serverLink.queueForRoomID(roomID){
            (result: [[AnyObject]]) in
            serverLink.musicList = result
            self.tableView.reloadData()
        }
        
    }
}
