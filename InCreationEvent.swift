//
//  InCreationEvent.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 07/03/2018.
//  Copyright © 2018 CarlTesting. All rights reserved.
//

import Foundation


class InCreationEvent {
    
    
    var eventTitle: String
    var date: Date?
    var weekDay: String?
    var duration: Int =  15
    var hourMin: String?
    var address: String?
    var longi: Double = 0.0
    var lati: Double = 0.0
    var description: String = "Description of event"
    var tripleFriendsClassRef: tripleFriendsCustomCollectionCell!
   
    
    
    init(title: String){
        self.eventTitle = title
    }
    
    
    
    
    
    
}
