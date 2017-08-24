//
//  EventInfo.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 27/09/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class EventInfo: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate { //Not used at the moment
    
    @IBOutlet weak var chatIcon: UIButton!
    @IBOutlet weak var numberAttending: UILabel!
    @IBOutlet weak var weekdayAndTime: UILabel!

    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var topPicButton: UIButton!
    private var _event: eventInformation!

    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var creatorImage: UIImageView!
    
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    
    var userID: String!
    
    var event: eventInformation {
        get {
            return _event
        } set {
            _event = newValue
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.weekdayAndTime.text = "\(self._event.timeYYYYMMDDHHMM!)"
        self.chatIcon.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.userID = FIRAuth.auth()?.currentUser?.uid
        if userID != _event.creatorID{
            self.topPicButton.isHidden = true
        }
        imagePicker.delegate = self
        
        //TODO: update top image to eventimage
        self.topImage.clipsToBounds = true
        self.eventTitleLabel.text = _event.title
        self.creatorImage.image = _event.creatorImage
        self.creatorImage.layer.borderWidth = 3
        self.creatorImage.layer.masksToBounds = false
        self.creatorImage.layer.borderColor = UIColor.white.cgColor
        self.creatorImage.layer.cornerRadius = 65 //based on fixed width in storyboard
        self.creatorImage.clipsToBounds = true
        self.ref.child("eventInfo").child("\(self._event.eventID!)").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let att = value?["numberAttending"]{
                self.numberAttending.text = "\(att)"
            }
        }) { (error) in
            print(error.localizedDescription)
        }

        


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func imOut(_ sender: AnyObject) {
        //must check firebase status!!!! instead of _event.attendingStatus
        
        self.ref.child("eventMembers").child("\(_event.eventID!)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            let status = value?["\((FIRAuth.auth()?.currentUser?.uid)!)"] as! String
            self._event.attendingStatus = status
            if self._event.attendingStatus == "IN" {
                //update firebase and event
                
                
                self.ref.child("eventInfo").child("\(self._event.eventID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    let numberAttending = (value?["numberAttending"] as! Int) - 1
                    self.numberAttending.text = "\(numberAttending)"
                    self.ref.child("eventInfo/\(self._event.eventID!)/numberAttending").setValue(numberAttending)
                    self._event.attendingStatus = "OUT"
                    self.ref.child("eventMembers/\(self._event.eventID!)/\(self.userID!)").setValue("OUT")
                    self.numberAttending.text = "\(numberAttending)"
                    // ...
                }) { (error) in
                    print(error.localizedDescription)
                }

            
            // ...
            }}) { (error) in
            print(error.localizedDescription)
        }

            
            
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func imIn(_ sender: AnyObject) {
        //must check firebase status
        
        self.ref.child("eventMembers").child("\(_event.eventID!)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            
            let status = value?["\((FIRAuth.auth()?.currentUser?.uid)!)"] as! String
            self._event.attendingStatus = status
            if self._event.attendingStatus == "OUT" {
                //update firebase and event
                
                
                self.ref.child("eventInfo").child("\(self._event.eventID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    let numberAttending = (value?["numberAttending"] as! Int) + 1
                    self.numberAttending.text = "\(numberAttending)"
                    self.ref.child("eventInfo/\(self._event.eventID!)/numberAttending").setValue(numberAttending)
                    self._event.attendingStatus = "OUT"
                    self.ref.child("eventMembers/\(self._event.eventID!)/\(self.userID!)").setValue("IN")
                    self.numberAttending.text = "\(numberAttending)"
                    // ...
                }) { (error) in
                    print(error.localizedDescription)
                }
                
                
                // ...
            }}) { (error) in
                print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func topImageBtnPressed(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        print("tapped")
        present(self.imagePicker, animated: true, completion: nil)
    }
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.topImage.image = pickedImage
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    

}
