//
//  FeedAndGroupsViewController.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 03/11/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit

class FeedAndGroupsViewController: UIViewController, eventsCustomCollectionCellDelegate, groupsCustomCollectionCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate {

    
    @IBOutlet weak var feedAndGroupsCollectionView: UICollectionView!
    
    @IBOutlet weak var createNew: UIButton!
    
    @IBOutlet weak var groupsLabel: UILabel!
    
    @IBOutlet weak var feedLabel: UILabel!
    
    var eventClassRef: eventsCustomCollectionCell = eventsCustomCollectionCell()
    var groupClassRef: groupsHomeCustomCollectionCell = groupsHomeCustomCollectionCell()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FBSDKAccessToken.current() == nil {
            print("accesstoken in feed = nil ")
            //go back to login screen
            self.performSegue(withIdentifier: "feedGroupToLogin", sender: nil)
        }
        UIApplication.shared.isStatusBarHidden = false
        self.groupsLabel.alpha = 0
        
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        

        feedAndGroupsCollectionView.dataSource = self
        feedAndGroupsCollectionView.delegate = self
        
        if let layout = feedAndGroupsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        feedAndGroupsCollectionView.isPagingEnabled = true
        feedAndGroupsCollectionView.isUserInteractionEnabled = true
        
        feedAndGroupsCollectionView?.register(eventsCustomCollectionCell.self, forCellWithReuseIdentifier: "eventsCustomCell")
        feedAndGroupsCollectionView?.register(groupsHomeCustomCollectionCell.self, forCellWithReuseIdentifier: "groupsHomeCustomCell")
        
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(sender:)))
            gesture.direction = direction
            self.view.addGestureRecognizer(gesture)
        }
        
    }
    
    //used for segue to eventinfo
    var latestEventCell: eventUICell2!
    var latestEventCollectionCell: eventsCustomCollectionCell!
    var latestIndexPath: IndexPath!
    
    func didClick(collectionCell:eventsCustomCollectionCell,eventCell: eventUICell2, indexPathInTableView: IndexPath){
        if var collectionIndex = feedAndGroupsCollectionView.indexPath(for: collectionCell){
            if var cellIndex = collectionCell.events.indexPath(for: eventCell){
                //perform segue
                
                eventCell.profilePicture.alpha = 0
                eventCell.title.alpha = 0
                latestEventCell = eventCell
                latestEventCollectionCell = collectionCell
                latestIndexPath = indexPathInTableView
                
                
                performSegue(withIdentifier: "segueFeedToEvent", sender: self)
                
            }
        }
    }
    
    func didClick(collectionCell:groupsHomeCustomCollectionCell,groupCell: groupCell){
        if let collectionIndex = feedAndGroupsCollectionView.indexPath(for: collectionCell){
            if let cellIndex = collectionCell.groupList.indexPath(for: groupCell){
                print(collectionIndex.row,cellIndex.row)
                //perform segue
            }
        }
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer){
        print(sender.direction)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueFeedToEvent" {
            if let destVC = segue.destination as? eventInformationVC {
                if let eventCell = latestEventCell {
                    //Change profile picture and text in cell
                    eventCell.profilePicture.alpha = 0
                    eventCell.title.alpha = 0
                    
                    destVC.eventCell = eventCell
                    //Profile picture
                    destVC.profilePicture.image = eventCell.profilePicture.image
                    destVC.profilePicture.frame = CGRect(x: eventCell.profilePicture.frame.minX, y: eventCell.frame.minY + eventCell.profilePicture.frame.minY+feedAndGroupsCollectionView.frame.minY-latestEventCollectionCell.events.contentOffset.y, width: eventCell.profilePicture.frame.width, height: eventCell.profilePicture.frame.height)
                    
                    
                    destVC.profilePicture.layer.borderWidth = 2
                    destVC.profilePicture.layer.masksToBounds = false
                    destVC.profilePicture.layer.borderColor = UIColor.white.cgColor
                    destVC.profilePicture.layer.cornerRadius = destVC.profilePicture.frame.size.height/2
                    destVC.profilePicture.clipsToBounds = true
                    destVC.profilePicture.contentMode = .scaleAspectFill
                    
                    //Event title
                    destVC.eventTitle.text = eventCell.title.text
                    destVC.eventTitle.frame = CGRect(x: eventCell.title.frame.minX, y: eventCell.frame.minY + feedAndGroupsCollectionView.frame.minY+eventCell.frame.height/2-eventCell.title.frame.height/2-self.latestEventCollectionCell.events.contentOffset.y, width: destVC.eventTitle.frame.width, height: destVC.eventTitle.frame.height)
                    destVC.eventTitle.sizeToFit()
                    
                    //TODO: event picture
                    destVC.eventPicture.image = #imageLiteral(resourceName: "shutterstock_139712587")
                    
                    //Time
                    destVC.eventTime.text = eventCell.time.text
                    destVC.eventTime.frame = CGRect(x: eventCell.time.frame.minX, y: eventCell.time.frame.minY + eventCell.frame.minY + feedAndGroupsCollectionView.frame.minY - self.latestEventCollectionCell.events.contentOffset.y, width: eventCell.time.frame.width, height: eventCell.time.frame.height)
                    destVC.eventTime.sizeToFit()
                    
                    
                    //address
                    destVC.address.text = eventCell.address
                    destVC.address.sizeToFit()
                    destVC.address.frame = CGRect(x: -UIScreen.main.bounds.width*2, y: eventCell.time.frame.minY + eventCell.frame.minY + feedAndGroupsCollectionView.frame.minY - self.latestEventCollectionCell.events.contentOffset.y+20, width: destVC.address.frame.width, height: destVC.address.frame.height)
                    
                    destVC.addressPin.frame = CGRect(x: -UIScreen.main.bounds.width*2, y: eventCell.time.frame.minY + eventCell.frame.minY + feedAndGroupsCollectionView.frame.minY - self.latestEventCollectionCell.events.contentOffset.y+20, width: 18, height: 18)
                    
                    destVC.address.sizeToFit()
                    
                    //attending
                    
                    destVC.numberAttending.text = eventCell.numberOfPeopleAttending.text
                    destVC.numberAttending.sizeToFit()
                    destVC.numberAttending.frame = CGRect(x: eventCell.numberOfPeopleAttending.frame.minX, y: eventCell.numberOfPeopleAttending.frame.minY+eventCell.frame.minY+feedAndGroupsCollectionView.frame.minY - self.latestEventCollectionCell.events.contentOffset.y, width: destVC.numberAttending.frame.width, height: destVC.numberAttending.frame.height)
                    
                    
                    
                    destVC.peoplePic.frame = CGRect(x: eventCell.peoplePic.frame.minX, y: eventCell.peoplePic.frame.minY+eventCell.frame.minY+feedAndGroupsCollectionView.frame.minY - self.latestEventCollectionCell.events.contentOffset.y, width: eventCell.peoplePic.frame.width, height: eventCell.peoplePic.frame.height)
                    
                    destVC.attendingStatus = eventCell.attending
                    if eventCell.attending != "NA" {
                        destVC.hasNotRespondedYet = false
                    } else {
                        destVC.hasNotRespondedYet = true
                    }
                    
                    
                    
                }
            }
        }
    }
    

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = self.view.frame.width
        let delta = min(max(feedAndGroupsCollectionView.contentOffset.x / width,0),1)
        let originalX = width/2 - self.feedLabel.frame.width/2
        if delta <= 0.5{
            self.feedLabel.frame = CGRect(x: originalX - delta/0.5*(originalX-self.groupsLabel.frame.minX), y: self.feedLabel.frame.minY, width: self.feedLabel.frame.width, height: self.feedLabel.frame.height)
            self.groupsLabel.alpha = 0
        }
        else if delta > 0.5 {
            self.groupsLabel.alpha = (delta-0.5)/0.5
            self.feedLabel.frame = CGRect(x: self.groupsLabel.frame.minX, y: self.feedLabel.frame.minY, width: self.feedLabel.frame.width, height: self.feedLabel.frame.height)
        }
  
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //var custom = UICollectionViewCell()
        //if indexpath = 0, then use the friends, otherwise groups
        if indexPath.row == 0 {
            
            let custom = feedAndGroupsCollectionView.dequeueReusableCell(withReuseIdentifier: "eventsCustomCell", for: indexPath) as! eventsCustomCollectionCell
            eventClassRef = custom
            custom.delegate = self
            return custom
        
        } else {
            let custom = feedAndGroupsCollectionView.dequeueReusableCell(withReuseIdentifier: "groupsHomeCustomCell", for: indexPath) as! groupsHomeCustomCollectionCell
            groupClassRef = custom
            custom.delegate = self
            return custom
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: feedAndGroupsCollectionView.frame.size.width, height: feedAndGroupsCollectionView.frame.size.height)
    }
    
    @IBAction func unwindToFeed(segue: UIStoryboardSegue) {
        let child = self.childViewControllers[0] as! eventInformationVC
        self.latestEventCollectionCell.events.alpha = 1
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            child.view.backgroundColor = UIColor(white: 1, alpha: 0.0)
            child.attendingCollectionView.alpha = 0
            child.messageImageView.alpha = 0
            child.backButton.alpha = 0
            child.eventPicture.alpha = 0
            
            child.profilePicture.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            child.profilePicture.frame = CGRect(x: self.latestEventCell.profilePicture.frame.minX, y: self.latestEventCell.frame.minY + self.latestEventCell.profilePicture.frame.minY+self.feedAndGroupsCollectionView.frame.minY-self.latestEventCollectionCell.events.contentOffset.y, width: self.latestEventCell.profilePicture.frame.width, height: self.latestEventCell.profilePicture.frame.height)
            
            child.eventTitle.frame = CGRect(x: self.latestEventCell.title.frame.minX, y: self.latestEventCell.frame.minY + self.feedAndGroupsCollectionView.frame.minY+self.latestEventCell.frame.height/2-self.latestEventCell.title.frame.height/2-self.latestEventCollectionCell.events.contentOffset.y, width: child.eventTitle.frame.width, height: child.eventTitle.frame.height)
            child.divider.frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY, width: UIScreen.main.bounds.width, height: child.dividerHeight)
            child.attendingCollectionView.frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY+child.dividerHeight, width: UIScreen.main.bounds.width, height: child.attendingCollectionView.frame.height)
            
            child.eventTime.frame = CGRect(x: self.latestEventCell.time.frame.minX, y: self.latestEventCell.time.frame.minY + self.latestEventCell.frame.minY + self.feedAndGroupsCollectionView.frame.minY - self.latestEventCollectionCell.events.contentOffset.y, width: self.latestEventCell.time.frame.width, height: self.latestEventCell.time.frame.height)
            
            child.address.frame = CGRect(x: -UIScreen.main.bounds.width*3, y: self.latestEventCell.time.frame.minY + self.latestEventCell.frame.minY + self.feedAndGroupsCollectionView.frame.minY - self.latestEventCollectionCell.events.contentOffset.y+20, width: child.address.frame.width, height: child.address.frame.height)
            
            
            child.addressPin.frame = CGRect(x: -UIScreen.main.bounds.width*3, y: self.latestEventCell.time.frame.minY + self.latestEventCell.frame.minY + self.feedAndGroupsCollectionView.frame.minY - self.latestEventCollectionCell.events.contentOffset.y+20, width: 18, height: 18)
            
            child.peoplePic.frame = CGRect(x: self.latestEventCell.peoplePic.frame.minX, y: self.latestEventCell.peoplePic.frame.minY + self.latestEventCell.frame.minY + self.feedAndGroupsCollectionView.frame.minY - self.latestEventCollectionCell.events.contentOffset.y, width: self.latestEventCell.peoplePic.frame.width, height: self.latestEventCell.peoplePic.frame.height)
            
            child.numberAttending.frame = CGRect(x: self.latestEventCell.numberOfPeopleAttending.frame.minX, y: self.latestEventCell.numberOfPeopleAttending.frame.minY + self.latestEventCell.frame.minY + self.feedAndGroupsCollectionView.frame.minY - self.latestEventCollectionCell.events.contentOffset.y, width: self.latestEventCell.numberOfPeopleAttending.frame.width, height: self.latestEventCell.numberOfPeopleAttending.frame.height)
            
            
            }) { (finished) in
                self.latestEventCell.profilePicture.alpha = 1
                self.latestEventCell.title.alpha = 1
                self.latestEventCell.alpha = 1
                child.willMove(toParentViewController: nil)
                child.view.removeFromSuperview()
                child.removeFromParentViewController()
                
        }
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        
    }
    
    @IBAction func unwindToFeedWithDeletedEvent(segue: UIStoryboardSegue) {
        
        let child = self.childViewControllers[0] as! eventInformationVC
        
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        let index = self.latestEventCollectionCell.eventCells.index(of: self.latestEventCell)
        self.latestEventCollectionCell.eventCells.remove(at: index! as! Int)
        
        self.latestEventCollectionCell.events.deleteRows(at: [self.latestIndexPath], with: UITableViewRowAnimation.automatic)
        
       
        child.willMove(toParentViewController: nil)
        child.view.removeFromSuperview()
        child.removeFromParentViewController()
        
        
    }
    print("halla")
    
    

    @IBAction func createNewSomething(_ sender: AnyObject) {
        let width = self.view.frame.width
        if feedAndGroupsCollectionView.contentOffset.x / width < 0.5 {
            self.performSegue(withIdentifier: "createNewEvent", sender: nil)
            
        } else {
            self.performSegue(withIdentifier: "createNewGroupName", sender: nil)
        }
    }
    @IBAction func settingsButtonClicked(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "feedAndGroupsToSettings", sender: self)
    }
    
    @IBAction func backFromCreatedEvent(segue: UIStoryboardSegue){
        
    }

}


protocol eventsCustomCollectionCellDelegate : class{
    func didClick(collectionCell:eventsCustomCollectionCell,eventCell: eventUICell2, indexPathInTableView: IndexPath)
}

class eventsCustomCollectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    let events = UITableView()
    
    var eventsFromFirebase = [eventInformation]() //[eventInformation] event with creator, eventName and number of People attending
    var eventCells = [eventUICell2]()
    var pastEventCells = [eventUICell2]()
    
    private var ref: FIRDatabaseReference!
    
    weak var delegate : eventsCustomCollectionCellDelegate?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.events.separatorStyle = .singleLine
        ref = FIRDatabase.database().reference()
        events.delegate = self
        events.dataSource = self
        addSubview(events)
        events.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        events.register(eventUICell2.self, forCellReuseIdentifier: "eventCell2")
        events.reloadData()
        //events.separatorColor = UIColor(colorLiteralRed: 255/255, green: 138/255, blue: 129/255, alpha: 1)
        events.separatorStyle = .none
        loadEvents()
        
        
        let directions: [UISwipeGestureRecognizerDirection] = [.right, .left]
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(sender:)))
        events.addGestureRecognizer(gesture)
        
    }
        
    func handleSwipe(sender: UISwipeGestureRecognizer){
        print("Mo")
    }
    
    
    func loadEvents(){
        let myGroup = DispatchGroup()
        if FBSDKAccessToken.current() == nil{
            return
        }
        if FBSDKAccessToken.current().userID != nil{
            let uid = FIRAuth.auth()?.currentUser?.uid // FIRAuth.auth()?.currentUser?.uid, should also be forced unwrap ! on .child(uid!) underneathh
            
            
            ref.child("user-events").child(uid!).queryOrdered(byChild: "time").observe( .childAdded, with: { snapshot in
                if let value = snapshot.value as? NSDictionary {
                    
                    let title = value.object(forKey: "name") as! String
                    let creator = value.object(forKey: "creator") as! String
                    let picURL = "https://graph.facebook.com/\(creator)/picture?width=400"
                    let address = value.object(forKey: "address") as! String
                    let time = value.object(forKey: "time") as! String
                    let description = value.object(forKey: "description") as! String
                    var status = "NA"
                    myGroup.enter()
                    self.ref.child("eventMembers").child("\(snapshot.key)").observeSingleEvent(of: .value, with: { (snapshot) in
                        
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
                    myGroup.enter()
                    self.ref.child("eventInfo").child("\(snapshot.key)").observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        
                        let value = snapshot.value as? NSDictionary
                        
                        if let attending2 = value?["numberAttending"] {
                            let att = attending2 as! Int
                            attending = att
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
                        
                        let newEvent = eventInformation(eventID: snapshot.key, title:title,picUrl: picURL,status: status,creatorID: creator,address: address, time: time, weekday: weekday, description: description,attending:attending)
                        self.eventsFromFirebase.append(newEvent)
                        self.setUpCell(newEventInfo: newEvent)
                    })
                    
                }
                
            })
        }
      
    }
    
    func setUpCell(newEventInfo: eventInformation){
        let eventInfo = self.eventsFromFirebase[self.eventsFromFirebase.count-1]
        let group = DispatchGroup()
        group.enter()
        let eventCell = eventUICell2()
        eventCell.setupCell(eventInfo: eventInfo)
        eventCell.updateCell(eventInformation: eventInfo,dispatchGroup:group)
        
        group.notify(queue: .main, execute: {
            let today = Date()
            if today.compare(eventCell.date) == .orderedDescending { //true if date before today
                self.pastEventCells.append(eventCell)
                self.pastEventCells.sort(by: { (cell1, cell2) -> Bool in
                    return cell1.date.compare(cell2.date) == .orderedDescending
                })
            } else {
                self.eventCells.append(eventCell)
                self.eventCells.sort(by: { (cell1, cell2) -> Bool in
                    return cell1.date.compare(cell2.date) == .orderedAscending
                })
            }
            let secondGroup = DispatchGroup()
            secondGroup.enter()
            self.updateSeparatorDays(group: secondGroup)
            secondGroup.notify(queue: .main, execute: { 
                self.events.reloadData()
            })
            })

    }
    
    var separatorWeekdays = [String]()
    var separatorShown = [String: Bool]()
    
    func updateSeparatorDays(group: DispatchGroup){
        var separatorDays = [String]()
        for cell in eventCells{
            let weekday = cell.weekDay
            if separatorDays.contains(weekday) == false {
                separatorDays.append(weekday)
            }
        }
        if pastEventCells.count > 0 {
            separatorDays.append("Past")
        }
        self.separatorWeekdays = separatorDays
        
        let keys = separatorShown.keys
        for sepDay in separatorDays{
            if !keys.contains(sepDay){
                self.separatorShown[sepDay] = false
            }
        }
        group.leave()
    }
    
    
    
    // Table view functions from here
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var potentialCells = [eventUICell2]()
        let weekday = self.separatorWeekdays[indexPath.section]
        if weekday != "Past" {
            for cell in self.eventCells{
                if cell.weekDay == weekday {
                    potentialCells.append(cell)
                }
            }
        } else {
            for cell in self.pastEventCells{
                potentialCells.append(cell)
            }
        }
        return potentialCells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didClick(collectionCell: self, eventCell: events.cellForRow(at: indexPath) as! eventUICell2, indexPathInTableView: indexPath)
        events.deselectRow(at: indexPath, animated: true)

    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let hoursToAddInSeconds: TimeInterval = 24 * 60 * 60 //one day
        var date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = NSLocale.current
        var convertedDate = dateFormatter.string(from: date as Date).localizedCapitalized
        if convertedDate == self.separatorWeekdays[section] {
            return "Today"
        } else {
            date = date.addingTimeInterval(hoursToAddInSeconds)
            convertedDate = dateFormatter.string(from: date as Date).localizedCapitalized
            if convertedDate == self.separatorWeekdays[section]{
                return "Tomorrow"
            }
        }
        return self.separatorWeekdays[section]
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let weekday = self.separatorWeekdays[section]
        var counter = 0
        if weekday != "Past" {
            for cell in self.eventCells{
                if cell.weekDay == weekday{
                    counter+=1
                }
            }
        } else {
            counter = self.pastEventCells.count
        }
        return counter
        
    }
    

    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return self.separatorWeekdays.count
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var index = 0
        for i in 0..<indexPath.section {
            index += self.events.numberOfRows(inSection: i)
        }
        index += indexPath.row
        var eventCell = eventUICell2()
        if index < self.eventCells.count {
            eventCell = self.eventCells[index]
        } else {
            eventCell = self.pastEventCells[index-self.eventCells.count]
        }
        
        if eventCell.shown == false {
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -UIScreen.main.bounds.height, 0,0)
            cell.layer.transform = rotationTransform
            let delay = (indexPath.row > 4 ? 0 : 0.1*Double(indexPath.section)+0.05*Double(indexPath.row))
            eventCell.shown = true
            UIView.animate(withDuration: 1, delay: delay, options: .curveEaseInOut , animations: {
                cell.layer.transform = CATransform3DIdentity
                }) { (finished) in
                    print(index)
                    
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if self.separatorShown[self.separatorWeekdays[section]] == false {
            view.alpha = 0
            let delay = (section > 4 ? 0 : 0.1*Double(section))
            self.separatorShown[self.separatorWeekdays[section]] = true
            UIView.animate(withDuration: 1, delay: delay, options: .curveEaseInOut , animations: {
                view.alpha = 1
            }) { (finished) in
                
            }
        }
    }
}


protocol groupsCustomCollectionCellDelegate : class{
    func didClick(collectionCell:groupsHomeCustomCollectionCell,groupCell: groupCell)
}

class groupsHomeCustomCollectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    let groupList = UITableView()
    
    weak var delegate : groupsCustomCollectionCellDelegate?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        groupList.delegate = self
        groupList.dataSource = self
        addSubview(groupList)
        groupList.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        groupList.keyboardDismissMode = .interactive
        
        groupList.register(groupCell.self, forCellReuseIdentifier: "groupCell")
        
        groupList.reloadData()
        
        groupList.separatorStyle = .none
        
    }
    
    //TODO: set size of table view
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didClick(collectionCell: self, groupCell: groupList.cellForRow(at: indexPath) as! groupCell)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if let cell: groupCell = self.groupList.dequeueReusableCell(withIdentifier: "groupCell") as? groupCell {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.textLabel?.text = globalGroups[indexPath.row]
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    
}
