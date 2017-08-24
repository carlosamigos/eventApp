//
//  eventUICell.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 02/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class eventUICell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var numberOfPeopleAttending: UILabel!
    let ref = FIRDatabase.database().reference()
    let storage = FIRStorage.storage()
    
    @IBOutlet weak var peoplePic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profilePicture.alpha = 0
        self.title.alpha = 0
        self.numberOfPeopleAttending.alpha = 0
        self.peoplePic.alpha = 0
    }
    
    
    func updateCell(eventInformation: eventInformation){
        
        let myGroup = DispatchGroup()
        self.title.text = eventInformation.title
        let storageRef = storage.reference(forURL: "gs://testeventapp-cd7d2.appspot.com")
        
        ref.child("eventInfo").child("\(eventInformation.eventID!)").observe(.value, with: { (snapshot) in
            // Get user value
            myGroup.enter()
            let value = snapshot.value as? NSDictionary
            
            if value != nil {
                let numberAttending = value?["numberAttending"] as! Int
                self.numberOfPeopleAttending.text = String(numberAttending)
            }
            myGroup.leave()
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //set profile picture
        if eventInformation.picUrl.characters.count > 0 { //check if it is data to get
            //to start with
            myGroup.enter()
            DispatchQueue.global().async {
                let ref = storageRef.child("images/\(eventInformation.creatorID!)/profilePicture.jpg")
            
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                ref.data(withMaxSize: 1 * 2024 * 2024) { (data, error) -> Void in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                    } else {
                        // Data for "images/island.jpg" is returned
                        let proPic: UIImage! = UIImage(data: data!)
                        self.profilePicture.image = proPic
                        self.profilePicture.contentMode = .scaleAspectFill
                        eventInformation.creatorImage = proPic
                        
                        
                    }
                    myGroup.leave()
                    
                }
            }
            //
            //DispatchQueue.global().async {
              //  do {
                //    let data = try Data(contentsOf: url!)
                  //  DispatchQueue.global().sync {
                    //    let pic = UIImage(data: data)
                      //  print("pic")
                       // print(pic)
                       // self.profilePicture.image = pic
                       // eventInformation.creatorImage = pic!
                        
                        
                    //}
                //} catch {
                //    print("error while getting picture")
                //}
           // }
            
            
            
            
            
        } else {
            
            self.profilePicture.image = #imageLiteral(resourceName: "people")
        }
        
        
        self.profilePicture.layer.borderWidth = 2
        self.profilePicture.layer.masksToBounds = false
        self.profilePicture.layer.borderColor = UIColor.lightGray.cgColor
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.height/2
        self.profilePicture.clipsToBounds = true
        self.profilePicture.contentMode = .scaleAspectFill
        myGroup.notify(queue: DispatchQueue.main) {
            UIView.animate(withDuration: 1.5, animations: {
                self.profilePicture.alpha = 1
                self.title.alpha = 1
                self.numberOfPeopleAttending.alpha = 1
                self.peoplePic.alpha = 1
            })
        }
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
