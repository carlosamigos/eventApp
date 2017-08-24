//
//  helperFunctions.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 19/11/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FBSDKCoreKit
import FirebaseAuth

var globalFriendsList = [facebookFriend]()

var selectedFriends = [facebookFriend]()
var selectedFriendsIds = [String]()

var groupStringList = ["Gutta i trondhiem","Smiths venner","Oslogutane"]



func updateFriendsList(){
    let request = FBSDKGraphRequest(graphPath: "/\(FBSDKAccessToken.current().userID!)/friends", parameters: nil, httpMethod: "GET")
    var returnData = NSDictionary()
    request?.start(completionHandler: { (FBSDKGraphRequestConnection, result, error) in
        if error != nil {
            print(error.debugDescription)
        } else {
            if let data = result{
                returnData = (data as! NSDictionary)
                updateFacebookPictures(friends: returnData)
            }
        }
        
    })
    
    var taggableFriends = [Any]()
    var nextURL = ""
    let myGroup = DispatchGroup()
    myGroup.enter()
    let request2 = FBSDKGraphRequest(graphPath:"/\(FBSDKAccessToken.current().userID!)/taggable_friends", parameters: nil, httpMethod: "GET")
    request2?.start(completionHandler: { (_, result, error) in
        if error != nil {
            print(error.debugDescription)
        } else {
            if let data = result{
                returnData = (data as! NSDictionary)
                let data = returnData["data"] as! NSArray
                taggableFriends += data
                nextURL = (returnData["paging"] as! NSDictionary)["next"] as! String
                myGroup.leave()
            }
        }
        
    })
    
    myGroup.notify(queue: DispatchQueue.main, execute: {
        if nextURL.characters.count > 0 {
            while true{
                if let url = URL(string: nextURL) {
                    do {
                        let data = try Data(contentsOf: url)
                        if let parsedData = try? JSONSerialization.jsonObject(with: data) as! [String:Any] {
                            let peopleArray = parsedData["data"] as! NSArray
                            taggableFriends += peopleArray
                            let pagingdata = parsedData["paging"] as! NSDictionary
                            let keysOfPaging = pagingdata.allKeys as NSArray
                            if keysOfPaging.contains("next") {
                                nextURL = pagingdata["next"] as! String
                                print(taggableFriends.count)
                            }else{
                                break
                            }
                        }
                    } catch {
                        // contents could not be loaded
                        break
                    }
                } else {
                    // the URL was bad!
                    break
                }
            }
        }
        
    })
 
}

func updateFacebookPictures(friends: NSDictionary){
    var newList = [facebookFriend]()
    //add try accept
    if friends.allKeys.count > 0{
        if let friendsArray = friends["data"] {
            for person in (friendsArray as! NSArray){ //persin is dictionary
                let personDict = (person as! NSDictionary)
                let name = personDict["name"]
                let id = personDict["id"]
                newList.append(facebookFriend(fullName: "\(name!)", facebookID: "\(id!)"))
            }
        }
    }
    globalFriendsList = newList
}
