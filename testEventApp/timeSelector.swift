//
//  timeSelector.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 01/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase
import FBSDKCoreKit
import FirebaseAuth



class timeSelector: UIViewController {
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    private var ref: DatabaseReference!

    var panGestureRecognizer: UIPanGestureRecognizer!
    var inCreationEvent: InCreationEvent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 5
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draggablePanGestureAction))
        self.view.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
    }

    @IBAction func nextBtnPressed(_ sender: AnyObject) {
        createEvent()
    }
   
    @IBAction func timeChanged(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
        let desc = timePicker.date.description as NSString
        if  desc.contains("am") || desc.contains("AM") || desc.contains("pm") || desc.contains("PM"){
            dateFormatter.dateFormat = "h:mm a"
            let selectedDate = dateFormatter.string(from: timePicker.date)
            self.nextBtn.setTitle(selectedDate, for: UIControlState.normal)
            
        }
        else {
            dateFormatter.dateFormat = "HH:mm"
            let selectedDate = dateFormatter.string(from: timePicker.date)
            self.nextBtn.setTitle(selectedDate, for: UIControlState.normal)
        }
    }
    
    func draggablePanGestureAction(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        view.frame.origin = CGPoint(x: 0, y: max(translation.y, 0) )
        if(translation.y > UIScreen.main.bounds.height * constants.gestureConstants.getureRemoveThreshold){
            view.removeGestureRecognizer(self.panGestureRecognizer)
            backBtnPressed(self)
        } else {
            let velocity = gesture.velocity(in: view)
            if gesture.state == .ended{
                if velocity.y >= constants.gestureConstants.gestureRemoveViewSpeed {
                    view.removeGestureRecognizer(self.panGestureRecognizer)
                    backBtnPressed(self)
                }
                else{
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.frame.origin = CGPoint(x: 0, y: 0)
                    })
                }
            }
        }
    }
    
    
    private func createEvent(){
        // TODO: add a check if the time chosen is yesterday or today
        timePicker.datePickerMode = UIDatePickerMode.time
        let dateFormatter = DateFormatter()
        let desc = timePicker.date.description as NSString
        if  desc.contains("am") || desc.contains("AM") || desc.contains("pm") || desc.contains("PM"){
            dateFormatter.dateFormat = "h:mm a"
            let newDate = dateFormatter.date(from: desc as String)
            dateFormatter.dateFormat = "HH:mm"
            let selectedTime = dateFormatter.string(from: newDate!)
            self.inCreationEvent?.hourMin = selectedTime
        }
        else {
            dateFormatter.dateFormat = "HH:mm"
            let selectedTime = dateFormatter.string(from: timePicker.date)
            self.inCreationEvent?.hourMin = selectedTime
        }
        
        let dato: NSDate = self.inCreationEvent?.date! as! NSDate
        let calendar = NSCalendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .year])
        let comp = calendar.dateComponents(unitFlags, from: dato as Date)
        var dateAsString = "\(comp.year!)/\(comp.month!)/\(comp.day!), \("00:00")" //format yyyy/mm/dd, hh:mm
        if let hourMin = inCreationEvent?.hourMin{
            dateAsString = "\(comp.year!)/\(comp.month!)/\(comp.day!), \(hourMin)" //format yyyy/mm/dd, hh:mm
        }
        
        // Add event
        let myGroup = DispatchGroup()
        let key = self.ref.child("eventInfo").childByAutoId().key
        let uid = Auth.auth().currentUser?.uid
        dateFormatter.dateFormat = "YYYY/MM/DD, HH:MM"
        var convertedDate = "No date"
        if let newDate = inCreationEvent?.date{
            convertedDate = dateFormatter.string(from: newDate)
        }
        let postEventInfo = ["name":inCreationEvent?.eventTitle ?? "No title","creator":uid!,"time":"\(dateAsString)","duration": inCreationEvent?.duration ?? 60,"weekday": inCreationEvent?.weekDay ?? "Monday","address": inCreationEvent?.address ?? "No Address", "latitute": inCreationEvent?.lati ?? 0.0, "longitude": inCreationEvent?.longi ?? 0.0,"numberAttending": 1, "description": inCreationEvent?.description ?? "No description"] as [String : Any]
        
        var postEventMembers = [uid!:"IN"] as [String : Any]
        let postPrivate = ["name":inCreationEvent?.eventTitle ?? "No title","creator":uid!,"time":"\(dateAsString)","duration": inCreationEvent?.duration ?? 60, "weekday": inCreationEvent?.weekDay ?? "Monday","address": inCreationEvent?.address ?? "No Address" , "latitute": inCreationEvent?.lati ?? 0.0, "longitude": inCreationEvent?.longi ?? 0.0,"description": inCreationEvent?.description ?? "No description"] as [String : Any]
        print(postEventInfo)
        print(postPrivate)
        var childUpdates = ["/user-events/\(uid!)/\(key)/": postPrivate]
        
        //Find friends that are invited
        var allFriends = [facebookFriend]()
        var facebookIDSet = Set<String>()
        for friend in selectedFriends{
            allFriends.append(friend)
            facebookIDSet.insert(friend.facebookID)
        }
        for group in selectedGroups{
            for firebaseIdofFriendToAdd in group.groupMemberFirebaseIDs{
                if let faceId = firebaseIDtoFacebookID[firebaseIdofFriendToAdd]{
                    if let faceBookFriend = facebookIDtoFacebookFriendMap[faceId]{
                        // check if facebook friend is in list:
                        if(!facebookIDSet.contains(faceId)){
                            allFriends.append(faceBookFriend)
                            facebookIDSet.insert(faceBookFriend.facebookID)
                        }
                    }
                }
            }
        }
        
        //Invite all friends
        for invitedFriend in allFriends{
            myGroup.enter()
            
            //if this fails, the user has not registered in the app yet
            self.ref.child("facebookUser/\(invitedFriend.facebookID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if (value?.allKeys.count)! > 0{
                    //update eventMembers and user-events
                    postEventMembers["\((value?["firebaseID"])!)"] = "NA"
                    
                    //add to childUpdates: "/user-events/\(uid!)/\(key)/": postPrivate
                    
                    childUpdates["/user-events/\((value?["firebaseID"])!)/\(key)/"] = postPrivate
                }
                myGroup.leave()
            })
            
        }
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            childUpdates["/eventInfo/\(key)"] = postEventInfo
            childUpdates["/eventMembers/\(key)"] = postEventMembers
            self.ref.updateChildValues(childUpdates)
        })
        resetSelectedFriendsAndGroups(tripleFriendsClassRef: (self.inCreationEvent?.tripleFriendsClassRef!)!)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        
        
    }
    

    
}
