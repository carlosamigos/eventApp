//
//  groupInformation.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 02/09/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth


class groupInformation {
    
    let groupId: String!
    let groupCreator: String!
    var groupName: String!
    var groupMemberFirebaseIDs: [String]
    private var ref: FIRDatabaseReference!
    
    init(groupId: String, groupCreator: String, groupName: String) {
        ref = FIRDatabase.database().reference()
        self.groupId = groupId
        self.groupCreator = groupCreator
        self.groupName = groupName
        self.groupMemberFirebaseIDs = [String]()
        addMembers()
        
    }
    
    func addMembers(){
        ref.child("groupInfo").child(groupId).child("groupMembers").observe(.childAdded, with: { (snapshot) in
            let firebaseKey = snapshot.key as! String
            self.groupMemberFirebaseIDs.append(firebaseKey)
            
        })
    }
    
    
    
}
