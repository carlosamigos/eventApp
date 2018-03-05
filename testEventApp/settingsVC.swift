//
//  settingsVCViewController.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 30/09/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FirebaseStorage
import GoogleSignIn
import GoogleAPIClientForREST
import EventKit




class settingsVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    //TODO: make user able to adjust profile picture to own face
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    private let scopes = [kGTLRAuthScopeCalendar]
    private let service = GTLRCalendarService()
    let signInButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))

    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var usersName: UILabel!
    @IBAction func signOutFromFBClicked(_ sender: AnyObject) {
        
        // sign out from firebase
        try! Auth.auth().signOut()
        
        //sign out from facebook
        FBSDKAccessToken.setCurrent(nil)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let LoginVC: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "login")
        self.present(LoginVC, animated: true, completion: nil)
        
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        self.profilePictureView.layer.borderWidth = 3
        self.profilePictureView.layer.masksToBounds = false
        self.profilePictureView.layer.borderColor = UIColor.white.cgColor
        self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.height/2
        self.profilePictureView.clipsToBounds = true
        
        
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGoogleLoginButton()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draggablePanGestureAction))
        self.view.addGestureRecognizer(panGestureRecognizer)
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://testeventapp-cd7d2.appspot.com")
        if let user = Auth.auth().currentUser {
            let name = user.displayName
            self.usersName.text = name
            if FBSDKAccessToken.current() != nil {
                
                let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                var docs: String = paths[0] as! String
                let fullPath =  "\(docs)/profilePicture.jpg"
                
                let image    = UIImage(contentsOfFile: "\(fullPath)")
                
                self.profilePictureView.image = image
                self.profilePictureView.contentMode = .scaleAspectFill
                
                if image == nil {
                let ref = storageRef.child("images/\((Auth.auth().currentUser?.uid)!)/profilePicture.jpg")
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                    ref.getData(maxSize: 1 * 2024 * 2024, completion: { (data, error) in
                        if (error != nil) {
                            // Uh-oh, an error occurred!
                        } else {
                            // Data for "images/island.jpg" is returned
                            let proPic: UIImage! = UIImage(data: data!)
                            self.profilePictureView.image = proPic
                            self.profilePictureView.contentMode = .scaleAspectFill
                        }
                    })
            
                }
                
            }else {
                print("accesstoken is nil")
            }
            
            
           
        } else {
            print("user not authorised")
        }
    }
    
    func setupGoogleLoginButton(){
        signInButton.center = view.center
        view.addSubview(signInButton)
        signInButton.isHidden = true
        
    }
    
    func getDocumentsDirectory() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return "\(documentsDirectory)"
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {});
    }
    
    func draggablePanGestureAction(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        view.frame.origin = CGPoint(x: 0, y: max(translation.y, 0) )
        if(translation.y > UIScreen.main.bounds.height * constants.gestureConstants.getureRemoveThreshold){
            view.removeGestureRecognizer(self.panGestureRecognizer)
            backButtonClicked(self)
        } else {
            let velocity = gesture.velocity(in: view)
            if gesture.state == .ended{
                if velocity.y >= constants.gestureConstants.gestureRemoveViewSpeed {
                    view.removeGestureRecognizer(self.panGestureRecognizer)
                    backButtonClicked(self)
                }
                else{
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.frame.origin = CGPoint(x: 0, y: 0)
                    })
                }
            }
        }
    }


    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
            self.signInButton.isHidden = false
        } else {
            self.signInButton.isHidden = true
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchEvents()
        }
    }
    
    // Construct a query and get a list of upcoming events from the user calendar
    func fetchEvents() {
        
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.maxResults = 10
        query.timeMin = GTLRDateTime(date: Date())
        query.singleEvents = true
        query.orderBy = kGTLRCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }
    
    // Display the start dates and event summaries in the UITextView
    func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRCalendar_Events,
        error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        var outputText = ""
        if let events = response.items, !events.isEmpty {
            for event in events {
                let start = event.start!.dateTime ?? event.start!.date!
                let end = event.end!.dateTime ?? event.end!.date!
                let startString = DateFormatter.localizedString(
                    from: start.date,
                    dateStyle: .short,
                    timeStyle: .short)
                let minutes = (end.dateComponents.hour! - start.dateComponents.hour!)*60 + (end.dateComponents.minute! - start.dateComponents.minute!)
                outputText += "\(startString) \((minutes)) mins: \(event.summary!)\n"
            }
        } else {
            outputText = "No upcoming events found."
        }
        print(outputText)
        addEvent()
        
    }
    
    func addEvent(){
        print("starting to add event")
        //Declares the new event
        var newEvent: GTLRCalendar_Event = GTLRCalendar_Event()
        
        //this is setting the parameters of the new event
        newEvent.summary = ("First event created!!")
        newEvent.location = ("800 Howard St., San Francisco, CA 94103")
        
        //I ran into some problems with the date formatting and this is what I ended with.
        
        //Start Date. The offset adds time to the current time so if you run the         program at 12:00 then it will record a time of 12:05 because of the 5 minute offset
        
        let startDateTime: GTLRDateTime = GTLRDateTime(date: Date(), offsetMinutes: 5)
        let startEventDateTime: GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime()
        startEventDateTime.dateTime = startDateTime
        newEvent.start = startEventDateTime
        print(newEvent.start!)
        
        //Same as start date, but for the end date
        let endDateTime: GTLRDateTime = GTLRDateTime(date: Date(), offsetMinutes: 50)
        let endEventDateTime: GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime()
        endEventDateTime.dateTime = endDateTime
        newEvent.end = endEventDateTime
        print(newEvent.end!)
        
        
        let service: GTLRCalendarService = GTLRCalendarService()
        
        //The query
        let query =
            GTLRCalendarQuery_EventsInsert.query(withObject: newEvent, calendarId:"primary")
        
        //This is the part that I forgot. Specify your fields! I think this will change when you add other perimeters, but I need to review how this works more.
        query.fields = "id";
        
        //This is actually running the query you just built
        self.service.executeQuery(
            query,
            completionHandler: {(_ callbackTicket:GTLRServiceTicket,
                _  event:GTLRCalendar_Event,
                _ callbackError: Error?) -> Void in}
                as? GTLRServiceCompletionHandler
        )
    }
    
    
    

    
    
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    

}
