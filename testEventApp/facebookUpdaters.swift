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

var globalFriendsList = [facebookFriend]() //friends with app
var globalTaggableFriends = [facebookFriendWithoutApp]() //all friends on facebook

func updateFriendsList(){
    if FBSDKAccessToken.current() == nil{
        return
    }
    //FRIENDS WITH APP
    let request = FBSDKGraphRequest(graphPath: "/\(FBSDKAccessToken.current().userID!)/friends", parameters: nil, httpMethod: "GET")
    var returnData = NSDictionary()
    DispatchQueue.global(qos: .background).async {
        request?.start(completionHandler: { (nil,result, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                if let data = result{
                    returnData = (data as! NSDictionary)
                    updateFacebookPictures(friends: returnData)
                }
            }
        })
    }
    
    var taggableFriendsPics = [Any]()
    
    func getTaggableFriendsPics(taggableFriends: [Any]) {
        
        var nextURL = ""
        let myGroup = DispatchGroup()
        myGroup.enter()
        let request2 = FBSDKGraphRequest(graphPath:"/\(FBSDKAccessToken.current().userID!)/taggable_friends?fields=picture.width(300).height(300)", parameters: nil, httpMethod: "GET") //add ?fields=picture.width(300).height(300) behind taggable_friends to get picture bigger
        request2?.start(completionHandler: { (_, result, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                if let data = result{
                    returnData = (data as! NSDictionary)
                    let data = returnData["data"] as! NSArray
                    taggableFriendsPics += data
                    nextURL = (returnData["paging"] as! NSDictionary)["next"] as! String
                    myGroup.leave()
                }
            }
            
        })
        myGroup.notify(queue: DispatchQueue.main, execute: {
            
            if nextURL.characters.count > 0 {
                DispatchQueue.global(qos: .background).async {
                    while true{
                        if let url = URL(string: nextURL) {
                            do {
                                let data = try Data(contentsOf: url)
                                if let parsedData = try? JSONSerialization.jsonObject(with: data) as! [String:Any] {
                                    
                                    let peopleArray = parsedData["data"] as! NSArray
                                    taggableFriendsPics += peopleArray
                                    let pagingdata = parsedData["paging"] as! NSDictionary
                                    let keysOfPaging = pagingdata.allKeys as NSArray
                                    if keysOfPaging.contains("next") {
                                        nextURL = pagingdata["next"] as! String
                                        print(taggableFriendsPics.count)
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
                    updateTaggableFriendsWithPics(taggableFriends: taggableFriends, taggableFriendsPics: taggableFriendsPics)
                }
            }
        })
        
        
    }

    
    
    //ALL FRIENDS
    var taggableFriends = [Any]()
    var nextURL = ""
    let myGroup = DispatchGroup()
    myGroup.enter()
    let request2 = FBSDKGraphRequest(graphPath:"/\(FBSDKAccessToken.current().userID!)/taggable_friends", parameters: nil, httpMethod: "GET") //add ?fields=picture.width(300).height(300) behind taggable_friends to get picture bigger
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
            DispatchQueue.global(qos: .background).async {
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
                //getTaggableFriendsPics(taggableFriends: taggableFriends)
                
            }
        }
    })
    
    
}

func updateTaggableFriendsWithPics(taggableFriends: [Any],taggableFriendsPics: [Any] ){
    //people is in the same order
    
    for i in 0...(taggableFriends.count-1) {
        let dict1 = taggableFriends[i] as! NSDictionary
        let name = dict1["name"] as! String
        
        if name == "Jakob Ismar Gulbrandsen"{
            print(taggableFriendsPics[i])
            print(taggableFriends[i])
        }
        //let dict2 = taggableFriendsPics[i] as! NSDictionary
        //let picDict = dict2["picture"] as! NSDictionary
        //let dataDict = picDict["data"] as! NSDictionary
        //let url = dataDict["url"] as! String
        
    }
}



func updateFacebookPictures(friends: NSDictionary){
    var newList = [facebookFriend]()
    //add try accept
    if friends.allKeys.count > 0{
        if let friendsArray = friends["data"] {
            print("facebook friends using app")
            print(friendsArray)
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
