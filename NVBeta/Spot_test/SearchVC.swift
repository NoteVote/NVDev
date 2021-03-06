//
//  SearchVC.swift
//  NVBeta
//
//  Created by Dustin Jones on 11/29/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func BackButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("SearchToActiveRoom", sender: nil)
    }
    @IBAction func SearchButtonPressed(sender: UIBarButtonItem) {
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverLink.musicOptions.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) as! SearchTableCell
        cell.songTitle.text! = serverLink.musicOptions[indexPath.row][1] as! String
        cell.artistLabel.text! = serverLink.musicOptions[indexPath.row][2] as! String
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //for Alpha version
        serverLink.getSongOptions(){
            (result: String) in print(result)
            self.tableView.reloadData()
        }
        
    }
    
    
}
