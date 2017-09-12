//
//  tripleFriendsCustomCollectionCell.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 12/09/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//

import UIKit

class tripleFriendsCustomCollectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    let friendsList = UITableView()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        friendsList.delegate = self
        friendsList.dataSource = self
        addSubview(friendsList)
        friendsList.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        globalFilteredFriends = globalFriendsList
        friendsList.keyboardDismissMode = .interactive
        
        friendsList.register(tripleFriendCell.self, forCellReuseIdentifier: "tripleFriendCell")
        
        friendsList.reloadData()
        
        friendsList.separatorStyle = .none
        
        
        
    }
    
    
    //TODO: set size of table view
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(ceil(Double(globalFilteredFriends.count)/3.0))
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if let cell: tripleFriendCell = self.friendsList.dequeueReusableCell(withIdentifier: "tripleFriendCell") as? tripleFriendCell {
            
            //get the three next faceBookIds
            let indexOfFirstFriend = (indexPath.row) * 3
            let totalIndexes = globalFilteredFriends.count-1
            let diff = Int(totalIndexes-indexOfFirstFriend)
            if diff == 0 {
                cell.updateFriendsCell1(friend1: globalFilteredFriends[indexOfFirstFriend])
            } else if diff == 1{
                cell.updatetripleFriendCell(friend1: globalFilteredFriends[indexOfFirstFriend],friend2: globalFilteredFriends[indexOfFirstFriend+1])
            } else {
                cell.updateFriendsCell3(friend1: globalFilteredFriends[indexOfFirstFriend],friend2: globalFilteredFriends[indexOfFirstFriend+1], friend3: globalFilteredFriends[indexOfFirstFriend+2])
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
            
            
            
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    
    
}
