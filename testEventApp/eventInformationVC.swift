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

class eventInformationVC: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{

    
    var eventCell = feedEventCell()
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
    
    let ref = Database.database().reference()
    
    let peoplePicSize = 18.0
    let attendingButtonHeight: CGFloat = 70
    var attendingButtonWidths: CGFloat = UIScreen.main.bounds.width
    var attendingStatus = "OUT"
    let dividerHeight: CGFloat = 0.3
    var attendingCollectionView: UICollectionView!
    var imInCell: imInCustomCollectionCell = imInCustomCollectionCell()
    var imOutCell: imOutCustomCollectionCell = imOutCustomCollectionCell()
    var eventsCustomCollectionCellRef: eventsCustomCollectionCell!
    
    //message related parameters and variables
    var inputTextField: UITextField!
    var messageTable: UITableView!
    var messageCurtain: UIView!
    var messagesText: VerticallyCenteredTextView!
    var messageButton: UIButton!
    var showOnlyLastMessage = true
    let cellId = "cellId"
    let numberOfCharactersPerLine = 65
    let heighOfTopView = 76
    let messageHeightPerLine = CGFloat(55)
    let spaceFromTableViewCellEdges = CGFloat(5)
    let bubbleEdgeSpace = CGFloat(80)
    let personalColor = UIColor(red: 0, green: 137.0/256, blue: 249.0/256, alpha: 1)
    let otherColor = UIColor(red:0.93, green: 0.93, blue: 0.93, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        setUpCollectionView()
        setupAttendingNumber()
        setupAddressAndPin()
        setupDivider()
        setupEventPicture()
        setupEventTitleAndEventTime()
        setUpProfilePicture()
        setUpBackButton()
        setUpPeoplePicture()
        setUpMessages()
    }
    
    func setUpMessages(){
        if(!offlineMode){
            eventCell.eventInformation.addChatListener(listener: self)
        }
        
        let bottomContainerView = UIView()
        bottomContainerView.backgroundColor = UIColor.white
        view.addSubview(bottomContainerView)
        
        bottomContainerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - attendingCollectionView.frame.height - 50, width: UIScreen.main.bounds.width, height: 50)
//        bottomContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
//        bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: attendingButtonHeight).isActive = true
//        bottomContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0.0).isActive = true
//        bottomContainerView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: bottomContainerView.rightAnchor, constant: 0.0).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor, constant: 0.0).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        sendButton.heightAnchor.constraint(equalTo: bottomContainerView.heightAnchor, constant: 0.0).isActive = true
        sendButton.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        
        inputTextField = UITextField()
        inputTextField.delegate = self
        inputTextField.placeholder = "Enter message"
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: bottomContainerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor, constant: 0.0).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 0.0).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: bottomContainerView.heightAnchor, constant: 0.0).isActive = true
        
        
        
        
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor(red: 220.0/256.0, green: 220.0/256.0, blue: 220.0/256.0, alpha: 1.0)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(seperatorLineView)
        seperatorLineView.leftAnchor.constraint(equalTo: bottomContainerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: bottomContainerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
       
        
        
        messageTable = UITableView()
        messageTable.separatorColor = UIColor.clear
        messageTable.delegate = self
        messageTable.dataSource = self
        messageTable.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        messageTable.backgroundColor = UIColor.white
        
        let messageTableHeightLastMessage = (eventCell.eventInformation.messages.count > 0 ) ? estimateFrameForText(text: eventCell.eventInformation.messages[eventCell.eventInformation.messages.count - 1].text).height + 30 : 100
//        let messageHeight = bottomContainerView.frame.minY - address.frame.maxY+distanceFromTitleToProfilePicture+5 + peoplePic.frame.height
//        messageTable.translatesAutoresizingMaskIntoConstraints = false
//        messageTable.topAnchor.constraint(equalTo: peoplePic.bottomAnchor).isActive = true
//        messageTable.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor).isActive = true
//        messageTable.widthAnchor.constraint(equalTo: bottomContainerView.widthAnchor).isActive = true
//
        
        messageTable.frame = CGRect(x: 0, y: bottomContainerView.frame.minY - messageTableHeightLastMessage - 8, width: UIScreen.main.bounds.width, height: messageTableHeightLastMessage)
        messageTable.contentInset = UIEdgeInsetsMake(0, 8, 0, 0)
        messageTable.allowsSelection = false
        
        if (eventCell.eventInformation.messages.count > 0){
            let indexPath = IndexPath(row: eventCell.eventInformation.messages.count-1, section: 0)
            messageTable.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        view.addSubview(messageTable)
        
        messageTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageTable.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageTable.scrollRectToVisible(CGRect(x: 0, y: messageTable.contentSize.height - messageTable.bounds.size.height, width: messageTable.bounds.size.width, height: messageTable.bounds.size.height), animated: true)
        
        let seperatorLineView2 = UIView()
        seperatorLineView2.backgroundColor = UIColor(red: 220.0/256.0, green: 220.0/256.0, blue: 220.0/256.0, alpha: 1.0)
        seperatorLineView2.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(seperatorLineView2)
        seperatorLineView2.leftAnchor.constraint(equalTo: bottomContainerView.leftAnchor).isActive = true
        seperatorLineView2.topAnchor.constraint(equalTo: bottomContainerView.bottomAnchor).isActive = true
        seperatorLineView2.widthAnchor.constraint(equalTo: bottomContainerView.widthAnchor).isActive = true
        seperatorLineView2.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
       
        
    }
    
    
    

    
    func setupAttendingNumber(){
        //attending number
        self.view.addSubview(self.numberAttending)
        let numberFontSize = 15.0
        self.numberAttending.textColor = constants.globalColors.happyMainColor
        self.numberAttending.font = UIFont(name: "Helvetica-Neue", size: CGFloat(numberFontSize))
    }
    
    func setupAddressAndPin(){
        self.address.font = UIFont(name: "Helvetica-Neue", size: CGFloat(20))
        self.address.font = UIFont.systemFont(ofSize: CGFloat(20), weight: UIFontWeightThin)
        self.view.addSubview(self.address)
        //self.addressPin.image = #imageLiteral(resourceName: "geoTag0.2x")
        self.addressPin.contentMode = .scaleAspectFill
        self.view.addSubview(self.addressPin)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "eventToChatSegue"){
            let dest = segue.destination as! eventChatViewController
            dest.event = eventCell.eventInformation
        } else if(segue.identifier == "segueEventToFeed"){
            //halla
        }
        
    }
    
    

    
    func setupDivider(){
        self.divider = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-self.attendingButtonHeight, width: UIScreen.main.bounds.width, height: self.dividerHeight))
        self.divider.backgroundColor = UIColor.lightGray
        self.divider.alpha = 0.5
        self.view.addSubview(self.divider)
    }
    
    func setupEventPicture(){
        eventPicture.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat(eventPictureHeight))
        eventPicture.contentMode = UIViewContentMode.scaleAspectFill
        eventPicture.alpha = 0.7
        eventPicture.clipsToBounds = true
        view.addSubview(eventPicture)
    }
    
    func setupEventTitleAndEventTime(){
        eventTitle.sizeToFit()
        self.eventTitle.font = UIFont(name: "Helvetica-Neue", size: CGFloat(25))
        self.eventTitle.font = UIFont.systemFont(ofSize: CGFloat(25), weight: UIFontWeightThin)
        view.addSubview(eventTitle)
        self.eventTime.font = UIFont(name: "Helvetica-Neue", size: CGFloat(18))
        self.eventTime.textColor = UIColor.lightGray
        view.addSubview(self.eventTime)
    }
    
    func setUpProfilePicture(){
        if profilePicture.image == nil{
            self.profilePicture.image = #imageLiteral(resourceName: "people")
        }
        view.addSubview(self.profilePicture)
        self.view.bringSubview(toFront: profilePicture)
    }
    
    func setUpBackButton(){
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
        self.view.bringSubview(toFront: self.backButton)
    }
    
    func setUpPeoplePicture(){
        self.peoplePic.image = #imageLiteral(resourceName: "people")
        self.peoplePic.contentMode = .scaleAspectFill
        self.view.addSubview(self.peoplePic)
        if !(eventCell.eventInformation.attendingStatus! == "NA") {
            if self.eventCell.eventInformation.attendingStatus! == "IN" {
                self.attendingCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
            } else {
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
        if eventCell.eventInformation.attendingStatus! == "NA"{
            // has not responded yet
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
        if eventCell.eventInformation.attendingStatus! == "NA" {
            fixAttendingButtonsFirstTime(indexPath: indexPath)
        } else {
            if indexPath.row == 0{
                self.attendingCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .left, animated: true)

            } else {
                self.attendingCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
            }
        }
    }
    
    func updateStatusInFirebase(withString: String){
        var currentStatusInDatabase = ""
        self.ref.child("eventMembers").child("\(self.eventCell.eventID)").observeSingleEvent(of: .value, with: { (snapshot1) in
            let value = snapshot1.value as? NSDictionary
            let status = value?["\((Auth.auth().currentUser?.uid)!)"] as! String
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
                        self.ref.child("eventMembers/\(self.eventCell.eventID)/\((Auth.auth().currentUser?.uid)!)").setValue("IN")
                        self.numberAttending.text = "\(newNumber)"
                        self.numberAttending.sizeToFit()
                    }
                    else if withString == "OUT" {
                        self.eventCell.attending = withString
                        let newNumber = numberAttending-1
                        self.ref.child("eventInfo/\(self.eventCell.eventID)/numberAttending").setValue(newNumber)
                        self.ref.child("eventMembers/\(self.eventCell.eventID)/\((Auth.auth().currentUser?.uid)!)").setValue("OUT")
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
                    self.attendingCollectionView.reloadData()
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
//                        self.messageImageView.frame = CGRect(x: 0, y: self.messageImageView.frame.minY, width: self.messageImageView.frame.width, height: self.messageImageView.frame.height)
                        }, completion: nil)

                    self.attendingStatus = "IN"

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
                    self.attendingCollectionView.reloadData()
                    self.attendingCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .left, animated: false)
                    self.attendingStatus = "OUT"
                    
            })
        }

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let screenWidth = UIScreen.main.bounds.width
        
        
        if !(eventCell.eventInformation.attendingStatus! == "NA"){
            let delta = min(max(0.0,scrollView.contentOffset.x/screenWidth),1.0)
            self.imInCell.imInLabel.frame = CGRect(x: (screenWidth/2-self.imInCell.imInLabel.frame.width/2-10.0)*delta+screenWidth/2-self.imInCell.imInLabel.frame.width/2, y: self.imInCell.imInLabel.frame.minY, width: self.imInCell.imInLabel.frame.width, height: self.imInCell.imInLabel.frame.height)
            self.imOutCell.imOutLabel.frame = CGRect(x: delta*(screenWidth/2-self.imOutCell.imOutLabel.frame.width/2-10)+10, y: self.imOutCell.imOutLabel.frame.minY, width: self.imOutCell.imOutLabel.frame.width, height: self.imOutCell.imOutLabel.frame.height)
            
            if delta == 1.0{
                self.attendingStatus = "OUT"
                updateStatusInFirebase(withString: "OUT")
                self.attendingCollectionView.backgroundColor = UIColor.white
                
                //if creator, ask if he wants to delete event
                
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
//                    self.messageImageView.frame = CGRect(x: -screenWidth, y: self.messageImageView.frame.minY, width: self.messageImageView.frame.width, height: self.messageImageView.frame.height)
                }, completion: nil)
                
                if (eventCell.creatorID == (Auth.auth().currentUser?.uid)!) {
                    let alert = UIAlertController(title: "Warning", message: "Do you want to delete event?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add the actions (buttons)
                    alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: { action in
                        self.deleteEvent(eventID: self.eventCell.eventID)
                    }))
                    alert.addAction(UIAlertAction(title: "Keep", style: UIAlertActionStyle.cancel, handler: { action in
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
//                    self.messageImageView.frame = CGRect(x: 0, y: self.messageImageView.frame.minY, width: self.messageImageView.frame.width, height: self.messageImageView.frame.height)
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
                            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
//                                self.messageImageView.frame = CGRect(x: 0, y: self.messageImageView.frame.minY, width: self.messageImageView.frame.width, height: self.messageImageView.frame.height)
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
        if eventCell.eventInformation.attendingStatus! == "NA" {
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
        self.ref.child("eventInfo").child(eventID).removeValue(completionBlock: { (error, DatabaseReference) in
            if error != nil{
                //fail
            } else {
                //success
                
            }
        })
        
        //find all users in event
        self.ref.child("eventMembers/\(eventID)").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            for userID in (value?.allKeys)! {
                self.ref.child("user-events").child("\(userID)").child(eventID).removeValue(completionBlock: { (error, DatabaseReference) in
                    if error != nil{
                        //fail
                    } else {
                        //success
                        self.eventsCustomCollectionCellRef.events.reloadData()
                        print("user-event deleted")
                        
                    }
                })
            }
            self.ref.child("eventMembers").child(eventID).removeValue(completionBlock: { (error, DatabaseReference) in
                if error != nil{
                    //fail
                } else {
                    
                }
            })

        })
        
        self.performSegue(withIdentifier: "segueEventToFeedDeletedEvent", sender: self)
    }
    
    
    
    //Messages
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventCell.eventInformation.messages.count
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16.0)], context: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let text = eventCell.eventInformation.messages[indexPath.row].text
        let height = estimateFrameForText(text: text!).height + 20
        return CGFloat(height + 10)
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showOnlyLastMessage = false
        messageTable.reloadData()
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            let newHeight = self.messageTable.frame.maxY - self.peoplePic.frame.maxY-8
            self.messageTable.frame = CGRect(x: self.messageTable.frame.minX, y: self.messageTable.frame.minY + self.messageTable.frame.height - newHeight, width: self.messageTable.frame.width, height: newHeight)
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = eventCell.eventInformation.messages[indexPath.row].text
        let senderId = eventCell.eventInformation.messages[indexPath.row].senderId
        let isPersonal = (Auth.auth().currentUser?.uid==senderId)
        let messageCell = ChatMessageCell()
        let width = estimateFrameForText(text: text!).width
        let height = estimateFrameForText(text: text!).height + 20
        messageCell.bubbleWidthAnchor?.constant = width + 32
        messageCell.frame = CGRect(x: 0, y: CGFloat(0), width: width, height: height)
        messageCell.textView.text = text
        messageCell.bubbleView.backgroundColor = isPersonal ? constants.globalColors.happyMainColor : constants.globalColors.greyMessageBubbleColor
        messageCell.textView.textColor = isPersonal ? UIColor.white : .black
        let tableViewCell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height + CGFloat(40)))
        tableViewCell.addSubview(messageCell)
        if(!isPersonal){
            let facebookId = firebaseIDtoFacebookID[senderId!]
            let friend = facebookIDtoFacebookFriendMap[facebookId!]
            messageCell.profileImageView.image = friend!.profilePicture
            messageCell.bubbleViewRightAnchor?.isActive = false
            messageCell.bubbleViewLeftAnchor?.isActive = true
            messageCell.profileImageView.isHidden = false
        } else {
            messageCell.profileImageView.isHidden = true
            messageCell.frame = CGRect(x: UIScreen.main.bounds.width - width, y: CGFloat(0), width: width, height: height)
        }
        return tableViewCell
    }
    
    func handleSendButton(){
        let currentDateTime = Date()
        if(inputTextField.text!.count == 0){
            return
        }
        if(offlineMode){
            offlineMessageList.append(inputTextField.text!)
            self.messageTable.reloadData()
            messageTable.scrollToRow(at: IndexPath(row: messageTable.numberOfRows(inSection: 0)-1, section: 0), at: .bottom, animated: true)
            return
        }
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        let eventId = eventCell.eventInformation.eventID
        let userId = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("eventMessages").child(eventId!).childByAutoId()
        var values = ["text": inputTextField.text!]
        values["time"] = formatter.string(from: currentDateTime)
        values["userId"] = userId
        ref.updateChildValues(values)
        inputTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButton()
        textField.text = ""
        return true
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








