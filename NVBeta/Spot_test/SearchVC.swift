//
//  SearchVC.swift
//  NVBeta
//
//  Created by uics15 on 12/1/15.
//  Copyright © 2015 uiowa. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ENSideMenuDelegate {
    
    var preView:String?
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        print("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        print("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        print("sideMenuShouldOpenSideMenu")
        return false
    }
    
    func sideMenuDidClose() {
        print("sideMenuDidClose")
    }
    
    func sideMenuDidOpen() {
        print("sideMenuDidOpen")
    }

    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func BackButtonPressed(sender: UIBarButtonItem) {
        if(preView == "Host"){
            performSegueWithIdentifier("Search_Host", sender: nil)
        }
        else{
            performSegueWithIdentifier("Search_ActiveRoom", sender: nil)
        }
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
        
        let customColor = UIView()
        customColor.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView = customColor
        
        cell.songURI = serverLink.musicOptions[indexPath.row][0] as! String
        cell.songTitle.text! = serverLink.musicOptions[indexPath.row][1] as! String
        cell.artistLabel.text! = serverLink.musicOptions[indexPath.row][2] as! String
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sideMenuController()?.sideMenu?.delegate = self;
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
            //for Alpha version
        serverLink.getSongOptions() {
            (result: String) in print(result)
            self.tableView.reloadData()
        }
    }
}
