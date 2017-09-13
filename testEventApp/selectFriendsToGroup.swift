//
//  selectFriendsToGroup.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 30/08/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FBSDKCoreKit
import FirebaseAuth

var selectedGroupFriends = [facebookFriend]()
var selectedGroupFriendsIds = [String]()
var globalFilteredFriends = [facebookFriend]()
var globalFilteredGroups = [groupInformation]()

class selectFriendsToGroup: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UISearchBarDelegate,UIGestureRecognizerDelegate {
    
    var nameOfGroup: String!
    var backButton: UIButton!
    
    //TODO: add that the keyboard disappears when search is clicked.
    
    @IBOutlet weak var collectionV: UICollectionView!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var inviteFriendsLabel: UILabel!
    
    private let ref = FIRDatabase.database().reference()
    
    let friendsString = "friends"
    let groupString = "groups"
    var currentPageString: String!
    
    
    var tripleFriendsClassRef: tripleFriendsCustomCollectionCell = tripleFriendsCustomCollectionCell()
    var groupClassRef: groupsCustomCollectionCell = groupsCustomCollectionCell()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionV.showsHorizontalScrollIndicator = false
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
        prepareBackButton()
        
        
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
        
        //add something to do when in offline mode
        
        let myGroup = DispatchGroup()
        let key = self.ref.child("groupInfo").childByAutoId().key
        let uid = FIRAuth.auth()?.currentUser?.uid
        var postGroupMembers = [uid!:"IN"] as [String : Any]
        let postGroupInfo = ["groupName":self.nameOfGroup as String,"groupCreator":uid!, "groupId":key] as [String : Any]
        
        //all updates into childUpdates
        var childUpdates = ["/user-groups/\(uid!)/\(key)/": postGroupInfo]
        
        
        for invitedFriend in selectedFriends{
            myGroup.enter()
            //TODO: use firebaseID instead of faceBookiD - make it such that users are added to the database when logged in
            
            //if this fails, the user has not registered in the app yet
            self.ref.child("facebookUser/\(invitedFriend.facebookID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if (value?.allKeys.count)! > 0{
                    //update groupMembers and user-groups
                    postGroupMembers["\((value?["firebaseID"])!)"] = "IN"
                    
                    //add to childUpdates: "/user-events/\(uid!)/\(key)/": postPrivate
                    
                    childUpdates["/user-groups/\((value?["firebaseID"])!)/\(key)/"] = postGroupInfo
                }
                myGroup.leave()
            })
            
        }
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            childUpdates["/groupInfo/\(key)"] = postGroupInfo
            self.ref.updateChildValues(childUpdates)
            let updateGroupMembers = ["/groupInfo/\(key)/groupMembers" : postGroupMembers]
            self.ref.updateChildValues(updateGroupMembers)
        })
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        resetSelectedFriendsAndGroups(tripleFriendsClassRef: tripleFriendsClassRef)
    }
}











