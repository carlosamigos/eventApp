//
//  friendsCell.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 06/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit

class friendsCell: UITableViewCell {  // NOT USED ANYMORE
    
    
    @IBOutlet weak var firstProPic: UIButton!
    @IBOutlet weak var secondProPic: UIButton!
    @IBOutlet weak var thirdProPic: UIButton!
    
    var friendsInCell = [facebookFriend]()

    
    let standardColor = UIColor.white.cgColor
    let tapColor = constants.globalColors.happyMainColor.cgColor
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        presetButton(button: firstProPic)
        presetButton(button: secondProPic)
        presetButton(button: thirdProPic)
    }
    
    func presetButton(button: UIButton){
        //TODO: add alpha = 0 which will be animated when pictures are ready
        button.backgroundColor = UIColor.white
        button.layer.borderColor = self.standardColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 90/2
        button.clipsToBounds = true
        button.titleLabel?.text = ""
        
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func updateFriendsCell1(friend1: facebookFriend){
        updateButton(button: firstProPic,friend: friend1)
        secondProPic.alpha = 0
        thirdProPic.alpha = 0
        friendsInCell = [friend1]
        
    }
    
    func updateFriendsCell2(friend1: facebookFriend, friend2: facebookFriend){
        updateButton(button: firstProPic,friend: friend1)
        updateButton(button: secondProPic, friend: friend2)
        thirdProPic.alpha = 0
        friendsInCell = [friend1,friend2]
    }
    
    func updateFriendsCell3(friend1: facebookFriend, friend2: facebookFriend, friend3: facebookFriend){
        updateButton(button: firstProPic,friend: friend1)
        updateButton(button: secondProPic, friend: friend2)
        updateButton(button: thirdProPic, friend: friend3)
        friendsInCell = [friend1,friend2,friend3]
    }
    
    func updateButton(button: UIButton, friend: facebookFriend){
        button.layer.borderColor = friend.selected ? tapColor : standardColor
        button.alpha = 1
        button.setImage(friend.profilePicture, for: .normal)
        
    }
    
    @IBAction func firstPicClicked(_ sender: AnyObject) {
        firstProPic.layer.borderColor = (firstProPic.layer.borderColor == standardColor ) ? standardColor :tapColor
        
        if friendsInCell[0].selected {
            friendsInCell[0].selected = false
            let indeks = selectedFriendsIds.index(of: friendsInCell[0].facebookID)
            selectedFriends.remove(at:indeks! )
            selectedFriendsIds.remove(at: indeks!)
        }else {
            friendsInCell[0].selected = true
            selectedFriendsIds.append(friendsInCell[0].facebookID)
            selectedFriends.append(friendsInCell[0])
        }
        
        
    }
    @IBAction func seconfPicClicked(_ sender: AnyObject) {
        secondProPic.layer.borderColor = (secondProPic.layer.borderColor == standardColor ) ? standardColor :tapColor
        
        if friendsInCell[1].selected {
            friendsInCell[1].selected = false
            let indeks = selectedFriendsIds.index(of: friendsInCell[1].facebookID)
            selectedFriends.remove(at:indeks! )
            selectedFriendsIds.remove(at: indeks!)
        }else {
            friendsInCell[1].selected = true
            selectedFriendsIds.append(friendsInCell[1].facebookID)
            selectedFriends.append(friendsInCell[1])
        }
    }
    @IBAction func thirdPicClicked(_ sender: AnyObject) {
        thirdProPic.layer.borderColor = (thirdProPic.layer.borderColor == standardColor ) ? standardColor :tapColor
        if friendsInCell[2].selected {
            friendsInCell[2].selected = false
            let indeks = selectedFriendsIds.index(of: friendsInCell[2].facebookID)
            selectedFriends.remove(at:indeks! )
            selectedFriendsIds.remove(at: indeks!)
        }else {
            friendsInCell[2].selected = true
            selectedFriendsIds.append(friendsInCell[2].facebookID)
            selectedFriends.append(friendsInCell[2])
        }
    }
    
    
    @IBAction func firstPicTapped(_ sender: AnyObject) {
        firstProPic.layer.borderColor = (firstProPic.layer.borderColor == standardColor ) ? tapColor : standardColor
    }
    @IBAction func secondTapped(_ sender: AnyObject) {
        secondProPic.layer.borderColor = (secondProPic.layer.borderColor == standardColor ) ? tapColor : standardColor
    }
    
    @IBAction func thirdTapped(_ sender: AnyObject) {
        thirdProPic.layer.borderColor = (thirdProPic.layer.borderColor == standardColor ) ? tapColor : standardColor
    }
    
   
    
    

}
