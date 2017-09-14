//
//  message.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 14/09/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//

import UIKit

class eventMessage{
    
    var senderId: String!
    var eventId: String!
    var day: NSDate!
    var text: String!
    
    init(senderId: String, eventId: String, timeStamp: String, text: String) {
        self.senderId = senderId
        self.eventId = eventId
        self.text = text
        
        //TODO: FIx TIME
    }
    
    
}
