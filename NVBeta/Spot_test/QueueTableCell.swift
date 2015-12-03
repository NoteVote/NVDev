//
//  QueueTableCell.swift
//  NVBeta
//
//  Created by uics15 on 11/3/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

class QueueTableCell: UITableViewCell {
    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    var songURI:String!
    
    @IBAction func voteButtonPressed(sender: UIButton) {
        if (serverLink.songsVoted[(userDefaults.objectForKey("roomID") as! String)]!.contains(songURI)){
            voteButton.setBackgroundImage(UIImage(named: "unvoted"), forState: UIControlState.Normal)
            voteButton.setTitleColor(UIColor(red: 125/255, green: 205/255, blue: 3/255, alpha: 1.0), forState: UIControlState.Normal)
            voteButton.setTitle(String(Int(voteButton.currentTitle!)!-1), forState: UIControlState.Normal)
            serverLink.incrementSongDown(self.songURI)
            
        } else {
            voteButton.setBackgroundImage(UIImage(named: "voted"), forState: UIControlState.Normal)
            voteButton.setTitleColor(UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0), forState: UIControlState.Normal)
            voteButton.setTitle(String(Int(voteButton.currentTitle!)!+1), forState: UIControlState.Normal)
            serverLink.incrementSongUp(self.songURI)
        
        }
        
        let roomID = userDefaults.objectForKey("roomID") as! String
        serverLink.saveRoomQueue(roomID)
    }
    
    func alreadyVoted(){
        voteButton.setBackgroundImage(UIImage(named: "voted"), forState: UIControlState.Normal)
        voteButton.setTitleColor(UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0), forState: UIControlState.Normal)
    }
    func notalreadyVoted(){
        voteButton.setBackgroundImage(UIImage(named: "unvoted"), forState: UIControlState.Normal)
        voteButton.setTitleColor(UIColor(red: 125/255, green: 205/255, blue: 3/255, alpha: 1.0), forState: UIControlState.Normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // initialization code.
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        //configure the view for the selected state.
    }

}
