//
//  SearchTableCell.swift
//  NVBeta
//
//  Created by uics15 on 12/1/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

class SearchTableCell: UITableViewCell {
    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var QueueButton: UIButton!
    var songURI:String!
    var queued = false

    @IBAction func QueueButtonPressed(sender: UIButton) {
        if(queued){
            QueueButton.setBackgroundImage(UIImage(named: "unvoted"), forState: UIControlState.Normal)
            queued = !queued
        
        } else {
            QueueButton.setBackgroundImage(UIImage(named: "voted"), forState: UIControlState.Normal)
            queued = !queued
            searchHandler.getURIwithPartial(songURI){
                (result: String) in
                serverLink.addSongToQueue([result,self.songTitle.text!,self.artistLabel.text!,1])
            }
        }
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
