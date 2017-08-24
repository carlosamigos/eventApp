//
//  eventInformationVC.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 05/11/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class eventInformationVC: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    
    var eventCell = eventUICell2()
    var profilePicture = UIImageView()
    var eventPictureHeight = 150.0
    var eventTitle = UILabel()
    var distanceFromTitleToProfilePicture: CGFloat = 16.0
    var eventPicture = UIImageView()
    var backButton: UIButton!
    var eventTime = UILabel()
    var divider = UIView()
    var address = UILabel()
    var addressPin = UIImageView()
    var numberAttending: UILabel = UILabel()
    var peoplePic = UIImageView()
    
    let ref = FIRDatabase.database().reference()
    
    let peoplePicSize = 18.0
    
    
    let attendingButtonHeight: CGFloat = 70
    var attendingButtonWidths: CGFloat = UIScreen.main.bounds.width
    
    var attendingStatus = "OUT"
    
    var messageImageView: UIImageView!
    
    let dividerHeight: CGFloat = 0.3
    
    var hasNotRespondedYet = false
    
    var attendingCollectionView: UICollectionView!
    
    var imInCell: imInCustomCollectionCell = imInCustomCollectionCell()
    var imOutCell: imOutCustomCollectionCell = imOutCustomCollectionCell()
    
    var doNotUpdateAttendingStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if profilePicture.image == nil{
            self.profilePicture.image = #imageLiteral(resourceName: "people")
        }
        
        setUpCollectionView()
        
        view.addSubview(self.profilePicture)
        eventTitle.sizeToFit()
        self.eventTitle.font = UIFont(name: "Helvetica-Neue", size: CGFloat(25))
        self.eventTitle.font = UIFont.systemFont(ofSize: CGFloat(25), weight: UIFontWeightThin)
        view.addSubview(eventTitle)
        
        self.eventTime.font = UIFont(name: "Helvetica-Neue", size: CGFloat(18))
        self.eventTime.textColor = UIColor.lightGray
        view.addSubview(self.eventTime)
        
        
        eventPicture.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat(eventPictureHeight))
        eventPicture.contentMode = UIViewContentMode.scaleAspectFill
        eventPicture.alpha = 0.7
        eventPicture.clipsToBounds = true
        view.addSubview(eventPicture)
        
        
        //backbutton
        self.backButton = UIButton(frame: CGRect(x: -5, y: 0, width: 66, height: 66))
        let buttonPicture = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        buttonPicture.image = #imageLiteral(resourceName: "backButtonColored")
        buttonPicture.contentMode = .scaleAspectFit
        self.backButton.setImage(buttonPicture.image, for: .normal)
        self.backButton.isUserInteractionEnabled = true
        self.backButton.imageEdgeInsets = UIEdgeInsetsMake(13, 20, 13, 20)
        self.backButton.addTarget(self, action: #selector(eventInformationVC.handleActionBackButton), for: .touchUpInside)
        self.view.addSubview(self.backButton)
        
        
        self.view.bringSubview(toFront: profilePicture)
        self.view.bringSubview(toFront: self.backButton)
        
        
        self.divider = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-self.attendingButtonHeight, width: UIScreen.main.bounds.width, height: self.dividerHeight))
        self.divider.backgroundColor = UIColor.lightGray
        self.divider.alpha = 0.5
        self.view.addSubview(self.divider)
        
        //add messages - height depends on last message!!
        self.messageImageView = UIImageView(frame: CGRect(x: (self.hasNotRespondedYet ? -UIScreen.main.bounds.width:0.0), y: UIScreen.main.bounds.height-self.attendingButtonHeight-self.dividerHeight-self.attendingButtonHeight, width: UIScreen.main.bounds.width, height: self.attendingButtonHeight))
        self.messageImageView.image = #imageLiteral(resourceName: "messageTest")
        self.messageImageView.clipsToBounds = true
        self.messageImageView.contentMode = UIViewContentMode.scaleAspectFit
        self.view.addSubview(self.messageImageView)
        print("1",self.messageImageView)
        
        self.address.font = UIFont(name: "Helvetica-Neue", size: CGFloat(20))
        self.address.font = UIFont.systemFont(ofSize: CGFloat(20), weight: UIFontWeightThin)
        
        self.view.addSubview(self.address)
        
        self.addressPin.image = #imageLiteral(resourceName: "geoTag0.2x")
        self.addressPin.contentMode = .scaleAspectFill
        self.view.addSubview(self.addressPin)
        
        
        
        //attending number and picture
        self.view.addSubview(self.numberAttending)
        let numberFontSize = 15.0
        self.numberAttending.textColor = constants.globalColors.happyMainColor
        self.numberAttending.font = UIFont(name: "Helvetica-Neue", size: CGFloat(numberFontSize))
        
        //People picture
        
        self.peoplePic.image = #imageLiteral(resourceName: "people")
        self.peoplePic.contentMode = .scaleAspectFill
        self.view.addSubview(self.peoplePic)
        
        if !self.hasNotRespondedYet {
            if self.attendingStatus == "IN" {
                print("go to in")
                self.attendingCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
            } else {
                print("go to out")
                self.attendingCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .left, animated: false)
            }
        }
    }

    
    func setUpCollectionView(){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        self.attendingCollectionView = UICollectionView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: self.attendingButtonHeight), collectionViewLayout: flowLayout)
        self.attendingCollectionView.delegate = self
        self.attendingCollectionView.dataSource = self
        self.attendingCollectionView.isPagingEnabled = true
        self.attendingCollectionView.register(imInCustomCollectionCell.self, forCellWithReuseIdentifier: "imInCell")
        self.attendingCollectionView.register(imOutCustomCollectionCell.self, forCellWithReuseIdentifier: "imOutCell")
        self.attendingCollectionView.isUserInteractionEnabled = true
        self.attendingCollectionView.showsHorizontalScrollIndicator = false
        self.attendingCollectionView.backgroundColor = constants.globalColors.happyMainColor
        view.addSubview(self.attendingCollectionView)
        if self.hasNotRespondedYet {
            self.attendingCollectionView.isScrollEnabled = false
            self.attendingButtonWidths = self.attendingButtonWidths/2
            self.attendingCollectionView.alwaysBounceHorizontal = true
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //var custom = UICollectionViewCell()
        //if indexpath = 0, then use the friends, otherwise groups
        if indexPath.row == 0 {
            
            let custom = attendingCollectionView.dequeueReusableCell(withReuseIdentifier: "imInCell", for: indexPath) as! imInCustomCollectionCell
            imInCell = custom
            return custom
            
        } else {
            let custom = attendingCollectionView.dequeueReusableCell(withReuseIdentifier: "imOutCell", for: indexPath) as! imOutCustomCollectionCell
            imOutCell = custom
            return custom
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.hasNotRespondedYet {
            fixAttendingButtonsFirstTime(indexPath: indexPath)
        } else {
            if indexPath.row == 0{
                print("got to out 2")
                self.attendingCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .left, animated: true)

            } else {
                print("got to in 2")
                self.attendingCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
            }
        }
    }
    
    func updateStatusInFirebase(withString: String){
        var currentStatusInDatabase = ""
        self.ref.child("eventMembers").child("\(self.eventCell.eventID)").observeSingleEvent(of: .value, with: { (snapshot1) in
            let value = snapshot1.value as? NSDictionary
            let status = value?["\((FIRAuth.auth()?.currentUser?.uid)!)"] as! String
            currentStatusInDatabase = status
            if currentStatusInDatabase != withString {
                //find current number of attendees
                self.ref.child("eventInfo").child("\(self.eventCell.eventID)").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    let numberAttending = (value?["numberAttending"] as! Int)
                    if withString == "IN" {
                        self.eventCell.attending = withString
                        let newNumber = numberAttending+1
                        self.ref.child("eventInfo/\(self.eventCell.eventID)/numberAttending").setValue(newNumber)
                        self.ref.child("eventMembers/\(self.eventCell.eventID)/\((FIRAuth.auth()?.currentUser?.uid)!)").setValue("IN")
                        self.numberAttending.text = "\(newNumber)"
                        self.numberAttending.sizeToFit()
                    }
                    else if withString == "OUT" {
                        self.eventCell.attending = withString
                        let newNumber = numberAttending-1
                        self.ref.child("eventInfo/\(self.eventCell.eventID)/numberAttending").setValue(newNumber)
                        self.ref.child("eventMembers/\(self.eventCell.eventID)/\((FIRAuth.auth()?.currentUser?.uid)!)").setValue("OUT")
                        self.numberAttending.text = "\(newNumber)"
                        self.numberAttending.sizeToFit()
                    }
                    // ...
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    
    func fixAttendingButtonsFirstTime(indexPath: IndexPath){
        let screenWidth = UIScreen.main.bounds.width
        //Not working with initial scroll at the moment (Dec. 20th 2016)
        
        if indexPath.row == 0 {
            //cell1 to the left
            
            updateStatusInFirebase(withString: "IN")
            
            let cell1 = self.attendingCollectionView.cellForItem(at: indexPath) as! imInCustomCollectionCell
            let indexPath2 = IndexPath(row: 1, section: 0)
            let cell2 = self.attendingCollectionView.cellForItem(at: indexPath2) as! imOutCustomCollectionCell
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                cell1.frame = CGRect(x: 0, y: 0, width: self.attendingButtonWidths*2, height: self.attendingButtonHeight)
                cell1.imInLabel.frame = CGRect(x: screenWidth/2-cell1.imInLabel.frame.width/2, y: cell1.imInLabel.frame.minY, width: cell1.imInLabel.frame.width, height: cell1.imInLabel.frame.height)
                cell2.frame = CGRect(x: UIScreen.main.bounds.width, y:0,width: self.attendingButtonWidths*2,height: self.attendingButtonHeight)
                cell2.imOutLabel.frame = CGRect(x: 10, y: cell2.imOutLabel.frame.minY, width: cell2.imOutLabel.frame.width, height: cell2.imOutLabel.frame.height)
                cell1.backgroundColor = constants.globalColors.happyMainColor
                cell1.imInLabel.textColor = UIColor.white
                }, completion: { (f) in
                    self.attendingButtonWidths = self.attendingButtonWidths*2
                    self.attendingCollectionView.isScrollEnabled = true
                    self.attendingCollectionView.isPagingEnabled = true
                    self.hasNotRespondedYet = false
                    self.attendingCollectionView.reloadData()
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                        self.messageImageView.frame = CGRect(x: 0, y: self.messageImageView.frame.minY, width: self.messageImageView.frame.width, height: self.messageImageView.frame.height)
                        }, completion: nil)

                    self.attendingStatus = "IN"
                    //cell2.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 138.0/255.0, blue: 129.0/255.0, alpha: 1)
                    //cell2.imOutLabel.textColor = UIColor.white
            })
        }
        else {
            //cell1 is to the right
            
            updateStatusInFirebase(withString: "OUT")
            let cell1 = self.attendingCollectionView.cellForItem(at: indexPath) as! imOutCustomCollectionCell
            let indexPath2 = IndexPath(row: 0, section: 0)
            let cell2 = self.attendingCollectionView.cellForItem(at: indexPath2) as! imInCustomCollectionCell
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                cell1.frame = CGRect(x: 0, y: 0, width: self.attendingButtonWidths*2, height: self.attendingButtonHeight)
                cell1.imOutLabel.frame = CGRect(x: screenWidth/2-cell1.imOutLabel.frame.width/2, y: cell1.imOutLabel.frame.minY, width: cell1.imOutLabel.frame.width, height: cell1.imOutLabel.frame.height)
                cell2.frame = CGRect(x: -UIScreen.main.bounds.width, y:0,width: self.attendingButtonWidths*2,height: self.attendingButtonHeight)
                cell2.imInLabel.frame = CGRect(x: screenWidth - cell2.imInLabel.frame.width-10, y: cell2.imInLabel.frame.minY, width: cell2.imInLabel.frame.width, height: cell2.imInLabel.frame.height)
                //cell1.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 138.0/255.0, blue: 129.0/255.0, alpha: 1)
                //cell1.imOutLabel.textColor = UIColor.white
                }, completion: { (f) in
                    self.attendingButtonWidths = self.attendingButtonWidths*2
                    self.attendingCollectionView.isScrollEnabled = true
                    self.attendingCollectionView.isPagingEnabled = true
                    self.hasNotRespondedYet = false
                    self.attendingCollectionView.reloadData()
                    self.attendingCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .left, animated: false)
                    self.attendingStatus = "OUT"
                    //cell2.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 138.0/255.0, blue: 129.0/255.0, alpha: 1)
                    //cell2.imInLabel.textColor = UIColor.white
                    
            })
        }

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let screenWidth = UIScreen.main.bounds.width
        if doNotUpdateAttendingStatus {
            return
        }
        
        if !self.hasNotRespondedYet{
            let delta = min(max(0.0,scrollView.contentOffset.x/screenWidth),1.0)
            self.imInCell.imInLabel.frame = CGRect(x: (screenWidth/2-self.imInCell.imInLabel.frame.width/2-10.0)*delta+screenWidth/2-self.imInCell.imInLabel.frame.width/2, y: self.imInCell.imInLabel.frame.minY, width: self.imInCell.imInLabel.frame.width, height: self.imInCell.imInLabel.frame.height)
            self.imOutCell.imOutLabel.frame = CGRect(x: delta*(screenWidth/2-self.imOutCell.imOutLabel.frame.width/2-10)+10, y: self.imOutCell.imOutLabel.frame.minY, width: self.imOutCell.imOutLabel.frame.width, height: self.imOutCell.imOutLabel.frame.height)
            
            if delta == 1.0{
                self.attendingStatus = "OUT"
                updateStatusInFirebase(withString: "OUT")
                self.attendingCollectionView.backgroundColor = UIColor.white
                
                //if creator, ask if he wants to delete event
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    self.messageImageView.frame = CGRect(x: -screenWidth, y: self.messageImageView.frame.minY, width: self.messageImageView.frame.width, height: self.messageImageView.frame.height)
                }, completion: nil)
                
                if (eventCell.creatorID == (FIRAuth.auth()?.currentUser?.uid)!) {
                    let alert = UIAlertController(title: "UIAlertController", message: "Do you want to delete event?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add the actions (buttons)
                    alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: { action in
                        print("Delete event")
                        self.deleteEvent(eventID: self.eventCell.eventID)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                        print("Cancel")
                        self.attendingCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
                        
                    }))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }

            }
            
            if delta == 0.0 {
                self.attendingStatus = "IN"
                updateStatusInFirebase(withString: "IN")
                self.attendingCollectionView.backgroundColor = constants.globalColors.happyMainColor
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                    print(self.messageImageView)
                    self.messageImageView.frame = CGRect(x: 0, y: self.messageImageView.frame.minY, width: self.messageImageView.frame.width, height: self.messageImageView.frame.height)
                    }, completion: nil)
            }
        } else {
            let delta = scrollView.contentOffset.x/screenWidth
            //if delta <0: orange background
            if delta <= 0{
                self.attendingCollectionView.backgroundColor = constants.globalColors.happyMainColor
                
                if delta < -0.15 {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                        let cell1 = self.imInCell
                        let cell2 = self.imOutCell
                        cell1.frame = CGRect(x: 0, y: 0, width: self.attendingButtonWidths*2, height: self.attendingButtonHeight)
                        cell1.imInLabel.frame = CGRect(x: screenWidth/2-cell1.imInLabel.frame.width/2, y: cell1.imInLabel.frame.minY, width: cell1.imInLabel.frame.width, height: cell1.imInLabel.frame.height)
                        cell2.frame = CGRect(x: UIScreen.main.bounds.width, y:0,width: self.attendingButtonWidths*2,height: self.attendingButtonHeight)
                        cell2.imOutLabel.frame = CGRect(x: 10, y: cell2.imOutLabel.frame.minY, width: cell2.imOutLabel.frame.width, height: cell2.imOutLabel.frame.height)
                        cell1.backgroundColor = constants.globalColors.happyMainColor
                        cell1.imInLabel.textColor = UIColor.white
                        }, completion: { (f) in
                            self.attendingCollectionView.isScrollEnabled = true
                            self.attendingCollectionView.isPagingEnabled = true
                            self.hasNotRespondedYet = false
                            
                            
                            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                                self.messageImageView.frame = CGRect(x: 0, y: self.messageImageView.frame.minY, width: self.messageImageView.frame.width, height: self.messageImageView.frame.height)
                                }, completion: nil)
                            self.attendingStatus = "IN"
                            
                            
                            
                            
                     
                    })
                }
            } else {
                self.attendingCollectionView.backgroundColor = UIColor.white
                if delta > 0.15 {
                    
                }
            }
           
        }
        
    
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if self.hasNotRespondedYet {
            return CGSize(width: self.attendingButtonWidths, height: attendingCollectionView.frame.size.height)
        } else {
            return CGSize(width: self.attendingButtonWidths, height: attendingCollectionView.frame.size.height)
        }
    }
    
 
    
    func handleActionBackButton(){
        //removeFromParentViewController()
        //dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "segueEventToFeed", sender: self)
    }
    
    func deleteEvent(eventID: String){
        
        self.ref.child("eventInfo").child(eventID).removeValue(completionBlock: { (error, FIRDatabaseReference) in
            if error != nil{
                //fail
            } else {
                //success
            }
        })
        
        
        //find all users in event
        
        
        
        self.ref.child("eventMembers/\(eventID)").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            print(value)
            for userID in (value?.allKeys)! {
                self.ref.child("user-events").child("\(userID)").child(eventID).removeValue(completionBlock: { (error, FIRDatabaseReference) in
                    if error != nil{
                        //fail
                    } else {
                        //success
                        print("user-event deleted")
                        
                    }
                })
            }
            self.ref.child("eventMembers").child(eventID).removeValue(completionBlock: { (error, FIRDatabaseReference) in
                if error != nil{
                    //fail
                } else {
                    
                }
            })

        })
        
        self.performSegue(withIdentifier: "segueEventToFeedDeletedEvent", sender: self)
        
        
        
        
        
        
        
        
       
        
        
        
    }
}


class imInCustomCollectionCell: UICollectionViewCell {
    
    var imInLabel: UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = constants.globalColors.happyMainColor
        self.imInLabel = UILabel(frame: self.frame)
        self.imInLabel.text = "I'm in"
        self.imInLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        self.imInLabel.sizeToFit()
        self.imInLabel.textColor = UIColor.white
        self.imInLabel.frame = CGRect(x: self.frame.width/2-self.imInLabel.frame.width/2, y: self.frame.height/2-self.imInLabel.frame.height/2, width: self.imInLabel.frame.width, height: self.imInLabel.frame.height)
        addSubview(self.imInLabel)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class imOutCustomCollectionCell: UICollectionViewCell {
    
    var imOutLabel: UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.imOutLabel = UILabel(frame: self.frame)
        self.imOutLabel.text = "I'm out"
        self.imOutLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        self.imOutLabel.sizeToFit()
        self.imOutLabel.textColor = constants.globalColors.happyMainColor
        self.imOutLabel.frame = CGRect(x: self.frame.width/2-self.imOutLabel.frame.width/2, y: self.frame.height/2-self.imOutLabel.frame.height/2, width: self.imOutLabel.frame.width, height: self.imOutLabel.frame.height)
        addSubview(self.imOutLabel)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}








