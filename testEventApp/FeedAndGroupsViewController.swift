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
        self.groupsLabel.alpha = 0
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
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //used for segue to eventinfo
    var latestEventCell: feedEventCell!
    var latestEventCollectionCell: eventsCustomCollectionCell!
    var latestIndexPath: IndexPath!
    
    func didClick(collectionCell:eventsCustomCollectionCell,eventCell: feedEventCell, indexPathInTableView: IndexPath){
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
    
    func didClick(collectionCell:groupsHomeCustomCollectionCell,groupCell: feedGroupCell){
        if let collectionIndex = feedAndGroupsCollectionView.indexPath(for: collectionCell){
            if let cellIndex = collectionCell.groups.indexPath(for: groupCell){
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
        let index = self.latestEventCollectionCell.eventCells.index(of: self.latestEventCell)
        self.latestEventCollectionCell.eventCells.remove(at: index! as! Int)
        
        self.latestEventCollectionCell.events.deleteRows(at: [self.latestIndexPath], with: UITableViewRowAnimation.automatic)
        
       
        child.willMove(toParentViewController: nil)
        child.view.removeFromSuperview()
        child.removeFromParentViewController()
        
        
    }
    
    

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
    func didClick(collectionCell:eventsCustomCollectionCell,eventCell: feedEventCell, indexPathInTableView: IndexPath)
}



protocol groupsCustomCollectionCellDelegate : class{
    func didClick(collectionCell:groupsHomeCustomCollectionCell,groupCell: feedGroupCell)
}

