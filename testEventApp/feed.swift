//
//  feed.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 27/09/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit


class feed: UIViewController,UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var events: UITableView!
    private var ref: FIRDatabaseReference!
    
    //TODO: add a .childRemoved listener
    
   
    var eventsFromFirebase = [eventInformation]() //[eventInformation] event with creator, eventName and number of People attending
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make sure accesstoken is existing
        if FBSDKAccessToken.current() == nil {
            print("accesstoken in feed = nil ")
            //go back to login screen
            self.performSegue(withIdentifier: "toLogin", sender: nil)
        }
        
        self.settingsBtn.imageEdgeInsets = UIEdgeInsetsMake(10,10,10,10)
        ref = FIRDatabase.database().reference()
        
        events.dataSource = self
        events.delegate = self
        
        
        //events.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        
        //load events from firebase with event names
        

        loadEvents()
        
        
    }
    

    

    
    func loadEvents(){
        var myGroup = DispatchGroup()
        //more efficient
        if FBSDKAccessToken.current().userID != nil {
            let uid = FIRAuth.auth()?.currentUser?.uid
            
            
            ref.child("user-events").child(uid!).queryOrdered(byChild: "time").observe( .childAdded, with: { snapshot in
                if let value = snapshot.value as? NSDictionary {
                    
                        let title = value.object(forKey: "name") as! String
                        let creator = value.object(forKey: "creator") as! String
                    
                        let picURL = "https://graph.facebook.com/\(creator)/picture?width=400"
                        let address = value.object(forKey: "address") as! String
                        let time = value.object(forKey: "time") as! String
                        let description = value.object(forKey: "description") as! String
                        var status = "NA"
                        self.ref.child("eventMembers").child("\(snapshot.key)").observeSingleEvent(of: .value, with: { (snapshot) in
                            myGroup.enter()
                            // Get user value
                            let value = snapshot.value as? NSDictionary
                            status = value?["\(uid!)"] as! String
                            
                            self.events.reloadData()
                            myGroup.leave()
                            // ...
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                        var attending = 1
                        var weekday = "Today"
                        self.ref.child("eventInfo").child("\(snapshot.key)").observeSingleEvent(of: .value, with: { (snapshot) in
                            // Get user value
                            myGroup.enter()
                            let value = snapshot.value as? NSDictionary
                        
                            if let attending2 = value?["numberAttending"] {
                                let att = attending2 as! Int
                                attending = att
                                print(attending)
                            }
                            if let day = value?["weekday"] {
                                weekday = day as! String
                                
                            }
                            self.events.reloadData()
                            myGroup.leave()
                        
                            // ...
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                    
                        //reason why it doesn't load at once is that the event is added before the data from Firebase is loaded
                    
                        myGroup.notify(queue: DispatchQueue.main, execute: {
                            print("finished all requests")
                            self.eventsFromFirebase.append(eventInformation(eventID: snapshot.key, title:title,picUrl: picURL,status: status,creatorID: creator,address: address, time: time, weekday: weekday, description: description,attending:attending))
                            
                            self.events.reloadData()
                        })
                    
                    }
                
            })
        }
        print("good")
        
        
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsFromFirebase.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if let cell: eventUICell = self.events.dequeueReusableCell(withIdentifier: "cell") as? eventUICell {
            
            let eventT = eventsFromFirebase[indexPath.row]
            
            cell.updateCell(eventInformation: eventT)
            

            return cell
        }else {
            return UITableViewCell()
            
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        events.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        let event = eventsFromFirebase[indexPath.row]
        performSegue(withIdentifier: "showEvent", sender: event)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EventInfo {
            if let eventFromFeed = sender as? eventInformation {
                destination.event = eventFromFeed
                
                
            }
        }
    }
    
    @IBAction func swipeBack(sender: UIStoryboardSegue){
        print("perform")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //TODO: remove deletebutton for some events
        
        let eventID = eventsFromFirebase[indexPath.row].eventID
        let creatorID = eventsFromFirebase[indexPath.row].creatorID
        if editingStyle == UITableViewCellEditingStyle.delete && creatorID == FIRAuth.auth()?.currentUser?.uid {
            eventsFromFirebase.remove(at: indexPath.row)
            //must delete from firebase as well
            self.ref.child("eventInfo").child(eventID!).removeValue(completionBlock: { (error, FIRDatabaseReference) in
                if error != nil{
                    //fail
                } else {
                    //success
                }
            })
            
            self.ref.child("user-events").child(creatorID!).child(eventID!).removeValue(completionBlock: { (error, FIRDatabaseReference) in
                if error != nil{
                    //fail
                } else {
                    //success
                }
            })
            
            self.ref.child("eventMembers").child(eventID!).removeValue(completionBlock: { (error, FIRDatabaseReference) in
                if error != nil{
                    //fail
                } else {
                    //success
                }
            })
            
            
            events.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    
    
    
    
    

    
    
    

}
