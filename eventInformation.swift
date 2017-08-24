//
//  eventInformation.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 03/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit

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
        
    }
    
    



}
