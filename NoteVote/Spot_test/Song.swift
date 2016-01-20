//
//  Song.swift
//  NoteVote
//
//  Created by Dustin Jones on 1/20/16.
//  Copyright © 2016 uiowa. All rights reserved.
//

import Foundation

class Song {
    
    var URI:String = ""
    var Name:String = ""
    var Artist:String = ""
    var Votes:Int = 0
    
    func setURI(uri:String){
        URI = uri
    }
    
    func setName(name:String){
        Name = name
    }
    
    func setArtist(artist:String){
        Artist = artist
    }
}