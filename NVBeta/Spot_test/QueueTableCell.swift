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
    
    
    @IBAction func voteButtonPressed(sender: UIButton) {
        
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
