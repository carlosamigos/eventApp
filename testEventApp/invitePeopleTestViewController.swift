//
//  invtePeopleTestViewController.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 09/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FBSDKCoreKit
import FirebaseAuth

var selectedFriends = [facebookFriend]()
var selectedFriendsIds = [String]()

var selectedGroups = [groupInformation]()


class invitePeopleViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UISearchBarDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var collectionV: UICollectionView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var inviteFriendsLabel: UILabel!
    private var ref: FIRDatabaseReference!
    var panGestureRecognizer: UIPanGestureRecognizer!

    
    let friendsString = "friends"
    let groupString = "groups"
    var currentPageString: String!
    
    var backButton: UIButton!
    var weekday: String = ""
    var dateFromChooseDay: Date = Date()
    var hourMin: String = ""
    var titleFromPrevView: String = ""
    var address: String = ""
    var longi: Double = 0.0
    var lati: Double = 0.0
    
    var tripleFriendsClassRef: tripleFriendsCustomCollectionCell = tripleFriendsCustomCollectionCell()
    var groupClassRef: groupsCustomCollectionCell = groupsCustomCollectionCell()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareBackButton()
        collectionV.showsHorizontalScrollIndicator = false
        ref = FIRDatabase.database().reference()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(invitePeopleViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        collectionV.dataSource = self
        collectionV.delegate = self
        searchBar.delegate = self
        searchBar.placeholder = "Search friends"
        currentPageString = friendsString
        
        if let layout = collectionV.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        collectionV.isPagingEnabled = true

        collectionV?.register(tripleFriendsCustomCollectionCell.self, forCellWithReuseIdentifier: "friendsCustomCell")
        collectionV?.register(groupsCustomCollectionCell.self, forCellWithReuseIdentifier: "groupsCustomCell")
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draggablePanGestureAction))
        self.view.addGestureRecognizer(panGestureRecognizer)
        

    }
    
    func prepareBackButton(){
        //backbutton
        backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 67, height: 67))
        backButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 39)
        backButton.setTitle("-", for: .normal)
        
        
        self.backButton.isUserInteractionEnabled = true
        
        self.backButton.addTarget(self, action: #selector(createNewGroupName.handleActionBackButton), for: .touchUpInside)
        self.view.addSubview(self.backButton)
        
        
    }
    
    func handleActionBackButton(){
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

  
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = self.view.frame.width
        if scrollView.contentOffset.x == width{
            self.searchBar.placeholder = "Search groups"
            currentPageString = groupString
        }else if scrollView.contentOffset.x == 0 {
            self.searchBar.placeholder = "Search friends"
            currentPageString = friendsString
        } else{
            
        }
    }
    

    
    func updateTextBtn(){
        nextBtn.titleLabel?.text = "Invite \(selectedFriends.count) friends!"
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var custom = UICollectionViewCell()
        //if indexpath = 0, then use the friends, otherwise groups
        if indexPath.row == 0 {
            custom = collectionV.dequeueReusableCell(withReuseIdentifier: "friendsCustomCell", for: indexPath) as! tripleFriendsCustomCollectionCell
            tripleFriendsClassRef = custom as! tripleFriendsCustomCollectionCell
        } else {
            custom = collectionV.dequeueReusableCell(withReuseIdentifier: "groupsCustomCell", for: indexPath) as! groupsCustomCollectionCell
            groupClassRef = custom as! groupsCustomCollectionCell
        }
        
        
        return custom
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: collectionV.frame.size.width, height: collectionV.frame.size.height)
    }
    
    func filterContentForFriendSearch(searchName: String){
        globalFilteredFriends = globalFriendsList.filter({ (facebookFriend) -> Bool in
            return facebookFriend.fullName.capitalized.contains(searchName.capitalized)
        })
    }
    
    func filterContentForGroupSearch(searchName: String){
        //needs to be updated
        globalFilteredGroups = globalGroupsFromFirebase.filter({ (groupInfo) -> Bool in
            return groupInfo.groupName.capitalized.contains(searchName.capitalized)
        })
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(currentPageString == friendsString){
            globalFilteredFriends = []
            //might be an error if classRef is not initiated yet
            tripleFriendsClassRef.friendsList.reloadData()
            if searchText.characters.count > 0 {
                //update filtered friends
                self.filterContentForFriendSearch(searchName: searchText)
            } else {
                globalFilteredFriends = globalFriendsList
            }
            tripleFriendsClassRef.friendsList.reloadData()
        } else if(currentPageString == groupString) {
            globalFilteredGroups = []
            //might be an error if classRef is not initiated yet
            groupClassRef.groupList.reloadData()
            if searchText.characters.count > 0 {
                //update filtered groups
                self.filterContentForGroupSearch(searchName: searchText)
            } else {
                globalFilteredGroups = globalGroupsFromFirebase
            }
            groupClassRef.groupList.reloadData()
        }
    }

    @IBAction func createEventButtonPressed(_ sender: AnyObject) {
        let myGroup = DispatchGroup()
        let key = self.ref.child("eventInfo").childByAutoId().key
        let uid = FIRAuth.auth()?.currentUser?.uid
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ""
        let convertedDate = dateFormatter.string(from: dateFromChooseDay)
        let postEventInfo = ["name":self.titleFromPrevView as String,"creator":uid!,"time":"\(convertedDate) \(self.hourMin)","weekday": self.weekday,"address": address, "latitute": lati, "longitude": longi,"numberAttending": 1, "description": "Description of the event"] as [String : Any]
        
        var postEventMembers = [uid!:"IN"] as [String : Any]
        let postPrivate = ["name":self.titleFromPrevView as String,"creator":uid!,"time":"\(convertedDate) \(self.hourMin)", "weekday": self.weekday,"address": address, "latitute": lati, "longitude": longi,"description": description] as [String : Any]
        
        var childUpdates = ["/user-events/\(uid!)/\(key)/": postPrivate]
        
        for invitedFriend in selectedFriends{
            myGroup.enter()
            //TODO: use firebaseID instead of faceBookiD - make it such that users are added to the database when logged in
            
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
        resetSelectedFriendsAndGroups(tripleFriendsClassRef: self.tripleFriendsClassRef)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        
    }
    
    func draggablePanGestureAction(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        view.frame.origin = CGPoint(x: 0, y: max(translation.y, 0) )
        if(translation.y > UIScreen.main.bounds.height * constants.gestureConstants.getureRemoveThreshold){
            view.removeGestureRecognizer(self.panGestureRecognizer)
            handleActionBackButton()
        } else {
            let velocity = gesture.velocity(in: view)
            if gesture.state == .ended{
                if velocity.y >= constants.gestureConstants.gestureRemoveViewSpeed {
                    view.removeGestureRecognizer(self.panGestureRecognizer)
                    handleActionBackButton()
                }
                else{
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.frame.origin = CGPoint(x: 0, y: 0)
                    })
                }
            }
        }
    }
    
        
}



    




