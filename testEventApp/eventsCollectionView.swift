//
//  eventsCollectionView.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 12/09/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit



class eventsCustomCollectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    let events = UITableView()
    var eventCells = [feedEventCell]()
    var pastEventCells = [feedEventCell]()
    let headerSize = 40.0
    
    private var ref: FIRDatabaseReference!
    
    weak var delegate : eventsCustomCollectionCellDelegate?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
 
        ref = FIRDatabase.database().reference()
        events.delegate = self
        events.dataSource = self
        addSubview(events)
        events.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        events.reloadData()
        events.separatorStyle = .none
        loadEvents()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe(sender:)))
        events.addGestureRecognizer(gesture)
        
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer){
        print("Mo")
    }
    
    
    func loadEvents(){
        let myGroup = DispatchGroup()
        if FBSDKAccessToken.current() == nil{
            print("something is wrong with logging in with facebook")
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
                        eventsFromFirebase.append(newEvent)
                        self.setUpCell(newEventInfo: newEvent)
                    })
                    
                }
                
            })
        }
        
    }
    
    func setUpCell(newEventInfo: eventInformation){
        let eventInfo = newEventInfo
        let group = DispatchGroup()
        group.enter()
        let eventCell = feedEventCell()
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
        var potentialCells = [feedEventCell]()
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
        //some error here
        return potentialCells[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didClick(collectionCell: self, eventCell: events.cellForRow(at: indexPath) as! feedEventCell, indexPathInTableView: indexPath)
        events.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = NSLocale.current
        var convertedDate = dateFormatter.string(from: date as Date).localizedCapitalized
        if convertedDate == self.separatorWeekdays[section] {
            return "Today"
        } else {
            let hoursToAddInSeconds: TimeInterval = 24 * 60 * 60 //one day from now
            date = date.addingTimeInterval(hoursToAddInSeconds)
            convertedDate = dateFormatter.string(from: date as Date).localizedCapitalized
            if convertedDate == self.separatorWeekdays[section]{
                return "Tomorrow"
            }
        }
        return self.separatorWeekdays[section]
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let blur = UIBlurEffect(style: .extraLight)
        let view = UIVisualEffectView(effect: blur)
        let label = UILabel()
        label.text = getHeaderText(section: section)
        label.font = label.font.withSize(20.0)
        label.sizeToFit()
        label.frame = CGRect(x: 20, y: CGFloat(headerSize)/2 -  label.frame.height/2, width: label.frame.width, height: label.frame.height)
        label.textColor = constants.globalColors.happyMainColor
        view.contentView.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(headerSize)
    }
    
    func getHeaderText(section: Int) -> String{
        var date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = NSLocale.current
        var convertedDate = dateFormatter.string(from: date as Date).localizedCapitalized
        if convertedDate == self.separatorWeekdays[section] {
            return "Today"
        } else {
            let hoursToAddInSeconds: TimeInterval = 24 * 60 * 60 //one day from now
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
        var eventCell = feedEventCell()
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
                //print(index)
                
            }
        }
    }
    

    

}
