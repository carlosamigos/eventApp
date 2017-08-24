//
//  dataSource.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 09/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

class dataSource {
    
    //All constants, references and global functions
    
    var mainStorageRef: FIRStorageReference {
        return FIRStorage.storage().reference(forURL: "gs://testeventapp-cd7d2.appspot.com")
    }
    
    var imageStorageRef: FIRStorageReference {
        return mainStorageRef.child("images")
    }
    
    func saveUser(uid: String){
        //morn
    }
    
}
