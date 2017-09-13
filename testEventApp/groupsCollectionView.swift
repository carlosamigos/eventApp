//
//  groupsCollectionView.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 12/09/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit


class groupsHomeCustomCollectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    let groups = UITableView()
    var groupCells = [feedGroupCell]()
    private var ref: FIRDatabaseReference!
    weak var delegate : groupsCustomCollectionCellDelegate?
    var groupsLoaded = false;
    
    override init(frame: CGRect){
        super.init(frame: frame)
        ref = FIRDatabase.database().reference()
        self.backgroundColor = UIColor.white
        groups.delegate = self
        groups.dataSource = self
        addSubview(groups)
        groups.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        groups.keyboardDismissMode = .interactive
        groups.register(feedGroupCell.self, forCellReuseIdentifier: "feedGroupCell")
        groups.reloadData()
        groups.separatorStyle = .none
        if(groupsLoaded == false){
            groupsLoaded = true
            loadGroups()
        }
        groups.reloadData()
        
        
    }
    
    //TODO: set size of table view
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didClick(collectionCell: self, groupCell: groups.cellForRow(at: indexPath) as! feedGroupCell)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalGroupsFromFirebase.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if let cell: feedGroupCell = self.groups.dequeueReusableCell(withIdentifier: "feedGroupCell") as? feedGroupCell {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.textLabel?.text = globalGroupsFromFirebase[indexPath.row].groupName
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func loadGroups(){
        let myGroup = DispatchGroup()
        if FBSDKAccessToken.current() == nil{
            return
        }
        
        if FBSDKAccessToken.current().userID != nil{
            let uid = FIRAuth.auth()?.currentUser?.uid // FIRAuth.auth()?.currentUser?.uid, should also be forced unwrap ! on .child(uid!)
            ref.child("user-groups").child(uid!).queryOrdered(byChild: "groupName").observe(.childAdded, with: { snapshot in
                if let value = snapshot.value as? NSDictionary{
                    
                    let groupName = value.object(forKey: "groupName") as! String
                    let groupCreator = value.object(forKey: "groupCreator") as! String
                    let groupId = value.object(forKey: "groupId") as! String
                    let group = groupInformation(groupId: groupId, groupCreator: groupCreator, groupName: groupName)
                    //add members
                    if(groupsIdMap[groupId] == nil){
                        globalGroupsFromFirebase.append(group)
                        groupsIdMap[groupId] = true
                        self.groups.reloadData()
                        print("group added ", value)
                        print(self.groupCells.count)
                        print(globalGroupsFromFirebase.count)
                    }
                }
            })
        }
        
    }
    
    
    
}

