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

class eventUICell2: UITableViewCell { //Currently used
    
    var profilePicture: UIImageView = UIImageView()
    var title: UILabel = UILabel()
    var numberOfPeopleAttending: UILabel = UILabel()
    var time: UILabel = UILabel()
    var address = "None"
    var attending = "NA"
    var eventID = ""
    var creatorID = ""
    
    
    let ref = FIRDatabase.database().reference()
    let storage = FIRStorage.storage()
    
    var date = Date()
    var weekDay = String()
    
    var peoplePic: UIImageView!
    
    var shown = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    func setupCell(eventInfo: eventInformation){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd, HH:mm" //format 2016/11/8, 13:30
        var date = dateFormatter.date(from: eventInfo.timeYYYYMMDDHHMM)
        self.date = date!
        self.attending = eventInfo.attendingStatus
        self.eventID = eventInfo.eventID
        self.creatorID = eventInfo.creatorID
        if self.attending != "NA" {
            self.shown = true
        }
        
        self.address = eventInfo.address
//        var indexOfNumber = 0
//        for ch in self.address.unicodeScalars {
//            if CharacterSet.decimalDigits.contains(ch){
//                break
//            }
//            indexOfNumber+=1
//        }
//        indexOfNumber = 0
//        let index = self.address.index(self.address.startIndex, offsetBy: indexOfNumber)
//        self.address = self.address.substring(to: index)
        
        
        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = NSLocale.current
        
        let convertedDate = dateFormatter.string(from: date!)
        self.weekDay = convertedDate
        
        let screenSize: CGRect = UIScreen.main.bounds
        let totalWidth = Double(screenSize.width) //TODO: make dynamic. Also know that cellHeight = 110
        let imageSize = 90.0
        let cellHeight = 110.0
        let titleHeight = 30.0
        let titleFontSize = 25.0
        
        self.backgroundColor = UIColor.white
        
        //Profile picture
        profilePicture = UIImageView(frame: CGRect(x: 1/4*(totalWidth-3*imageSize), y: cellHeight/2-imageSize/2, width: imageSize, height: imageSize))
        addSubview(profilePicture)
        
        //Title
        let xPos1 = 1/2*(totalWidth-3*imageSize)+imageSize
        let yPos1 = cellHeight/2-titleHeight/2
        let width1 = totalWidth-(1/2*(totalWidth-3*imageSize)+imageSize)-1/4*(totalWidth-3*imageSize)
        self.title = UILabel(frame: CGRect(x: xPos1, y: yPos1, width: width1, height: titleHeight))
        addSubview(self.title)
        self.title.font = UIFont(name: "Helvetica-Neue", size: CGFloat(titleFontSize))
        self.title.font = UIFont.systemFont(ofSize: CGFloat(titleFontSize), weight: UIFontWeightThin)
        self.title.baselineAdjustment = .alignCenters
        
        //Time
        let timeFontSize = 18.0
        let xPos4 = xPos1
        let yPos4 = yPos1 + titleHeight + 8
        self.time = UILabel(frame: CGRect(x: xPos4, y: yPos4, width: 10.0, height: Double(timeFontSize)))
        addSubview(self.time)
        self.time.textColor = UIColor.lightGray
        self.time.font = UIFont(name: "Helvetica-Neue", size: CGFloat(timeFontSize))
        
        //People attending
        let numberHeight = 20.0
        let numberFontSize = 15.0
        let xPos2 = totalWidth-1/4*(totalWidth-3*imageSize)-numberHeight
        let yPos2 = cellHeight/2+titleHeight/2+numberHeight/2+(numberHeight-numberFontSize)/2
        self.numberOfPeopleAttending = UILabel(frame: CGRect(x: CGFloat(xPos2), y: CGFloat(yPos2), width: CGFloat(numberHeight), height: CGFloat(numberHeight)))
        addSubview(self.numberOfPeopleAttending)
        self.numberOfPeopleAttending.textColor = constants.globalColors.happyMainColor
        self.numberOfPeopleAttending.font = UIFont(name: "Helvetica-Neue", size: CGFloat(numberFontSize))
        
        //People picture
        let peoplePicSize = 18.0
        let xPos3 = xPos2-8.0-Double(peoplePicSize)
        let yPos3 = yPos2+numberHeight/2-peoplePicSize/2-2
        self.peoplePic = UIImageView(frame: CGRect(x: CGFloat(xPos3), y: CGFloat(yPos3), width: CGFloat(peoplePicSize), height: CGFloat(peoplePicSize)))
        self.peoplePic.image = #imageLiteral(resourceName: "people")
        self.peoplePic.contentMode = .scaleAspectFill
        addSubview(self.peoplePic)
        
        
        
        self.profilePicture.alpha = 0
        self.title.alpha = 0
        self.numberOfPeopleAttending.alpha = 0
        self.peoplePic.alpha = 0
    }

    
    
    func updateCell(eventInformation: eventInformation,dispatchGroup:DispatchGroup){
        
        let myGroup = DispatchGroup()
        self.title.text = eventInformation.title
        let startIndex = eventInformation.timeYYYYMMDDHHMM.index(eventInformation.timeYYYYMMDDHHMM.endIndex, offsetBy: -5)
        self.time.text = eventInformation.timeYYYYMMDDHHMM.substring(from: startIndex)
        self.time.sizeToFit()
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
        } else {
            self.profilePicture.image = #imageLiteral(resourceName: "people")
        }
        
        self.profilePicture.layer.borderWidth = 2
        self.profilePicture.layer.masksToBounds = false
        self.profilePicture.layer.borderColor = UIColor.white.cgColor
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.height/2
        self.profilePicture.clipsToBounds = true
        self.profilePicture.contentMode = .scaleAspectFill
        myGroup.notify(queue: DispatchQueue.main) {
            UIView.animate(withDuration: 1.0, animations: {
                self.profilePicture.alpha = 1
                self.title.alpha = 1
                self.numberOfPeopleAttending.alpha = 1
                self.profilePicture.alpha = 1
                self.peoplePic.alpha = 1
                dispatchGroup.leave()
            })
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
