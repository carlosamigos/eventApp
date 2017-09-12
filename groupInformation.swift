//
//  groupInformation.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 02/09/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//

import Foundation


class groupInformation {
    
    let groupId: String!
    let groupCreator: String!
    var groupName: String!
    var groupMembers: [facebookFriend]
    
    init(groupId: String, groupCreator: String, groupName: String) {
        self.groupId = groupId
        self.groupCreator = groupCreator
        self.groupName = groupName
        self.groupMembers = []
    }
    
    public func addMember(facebookFriend: facebookFriend ){
        groupMembers.append(facebookFriend)
    }
    
    
}
