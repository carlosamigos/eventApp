//
//  facebookFriend.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 07/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit

class facebookFriend {

    var fullName: String!
    var facebookID: String!
//    var firebaseID: String!
    var profilePicture = UIImage()
    var selected = false

    
    init(fullName: String,facebookID: String){ //should add firebaseID: String
        self.fullName = fullName
        self.facebookID = facebookID
//        self.firebaseID = firebaseID
        
        //download image from Firebase database - when we are sure everyone has added their picture - not the case with Anders
        
        //temporary: download from link instead of firebase
        
        let myGroup = DispatchGroup()
        let picURL = "https://graph.facebook.com/\(self.facebookID!)/picture?width=300"
        
        myGroup.enter()
        DispatchQueue.global().async {
            let url = NSURL(string: picURL)
            if let data = NSData(contentsOf: url! as URL) {
                if let image = UIImage(data: data as Data){
                    self.profilePicture = image
                    myGroup.leave()
                    
                }
            }
            
        }
        myGroup.notify(queue: DispatchQueue.main, execute: {
            //print("profileImage downloaded")
        })
        
    }

}


class facebookFriendWithoutApp {
    var fullName: String!
    var profilePicture = UIImage()
    var hashID: String!
    
    
    init(fullName: String, picURL: String, hashID: String) {
        self.fullName = fullName
        self.hashID = hashID
        updatePicture(picURL: picURL)
    }
    
    func updatePicture(picURL: String) {
        let myGroup = DispatchGroup()
        myGroup.enter()
        DispatchQueue.global().async {
            let url = NSURL(string: picURL)
            if let data = NSData(contentsOf: url! as URL) {
                if let image = UIImage(data: data as Data){
                    self.profilePicture = image
                    myGroup.leave()
                }
            }
        }
        myGroup.notify(queue: DispatchQueue.main, execute: {
            //print("profileImage downloaded")
        })
    }
    
}
