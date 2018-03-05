//
//  eventInformation.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 03/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import Firebase

class eventInformation {
    
    var eventID: String!
    var title: String!
    var picUrl: String!
    var attendingStatus: String!
    var creatorImage: UIImage = UIImage()
    var creatorID: String!
    var address: String!
    var timeYYYYMMDDHHMM: String!
    var weekday: String!
    var description: String!
    var attending: Int!
    
    var messages = [eventMessage]()
    var chatListener: eventInformationVC!
    
    
    init(eventID: String,title: String,picUrl: String, status:String, creatorID: String, address: String, time: String,weekday: String, description: String, attending: Int){
        
        self.eventID = eventID
        self.title = title
        self.picUrl = picUrl
        self.attendingStatus = status
        self.creatorID = creatorID
        self.address = address
        self.timeYYYYMMDDHHMM = time
        self.description = description
        self.attending = attending
        self.weekday = weekday
        observeMessages()
    }
    
    func observeMessages(){
        if(offlineMode){
            return
        }
        let ref = Database.database().reference().child("eventMessages").child(self.eventID).observe(.childAdded, with: { snapshot in
            if let value = snapshot.value as? NSDictionary {
                let newMessage = eventMessage(senderId: value.object(forKey: "userId") as! String, eventId: self.eventID, timeStamp: value.object(forKey: "time") as! String, text: value.object(forKey: "text") as! String)
                self.messages.append(newMessage)
                if(self.chatListener != nil){
                    self.updateChatListener()
                }
            }
        })
    }
    
    func addChatListener(listener: eventInformationVC){
        self.chatListener = listener
    }
    
    func updateChatListener(){
        chatListener.messageTable.reloadData()
        chatListener.messageTable.scrollToRow(at: IndexPath(row: messages.count-1, section: 0), at: .bottom, animated: true)
    }
    
    
}
