//
//  tripleFriendCell.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 09/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit

class tripleFriendCell: UITableViewCell { 
    
    
    var friendsInCell = [facebookFriend]()
    
    
    let standardColor = UIColor.white.cgColor
    let tapColor = constants.globalColors.happyMainColor.cgColor
    
    var firstFriendButton: UIButton!
    var secondFriendButton: UIButton!
    var thirdFriendButton: UIButton!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style,reuseIdentifier: reuseIdentifier)
        setupButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButtons(){
        let screenSize: CGRect = UIScreen.main.bounds
        let totalWidth = screenSize.width //TODO: make dynamic. Also know that cellHeight = 110
        let imageSize: CGFloat = 90.0
        
        firstFriendButton = UIButton(frame: CGRect(x: 1/4*(totalWidth-3*imageSize), y: 110/2-imageSize/2, width: imageSize, height: imageSize))
        presetButton2(button: firstFriendButton)
        addSubview(firstFriendButton)
        secondFriendButton = UIButton(frame: CGRect(x: totalWidth/2-imageSize/2, y: 110/2-imageSize/2, width: imageSize, height: imageSize))
        presetButton2(button: secondFriendButton)
        addSubview(secondFriendButton)
        thirdFriendButton = UIButton(frame: CGRect(x: 1/4*(3*totalWidth-imageSize), y: 110/2-imageSize/2, width: imageSize, height: imageSize))
        presetButton2(button: thirdFriendButton)
        addSubview(thirdFriendButton)
        
        
        firstFriendButton.addTarget(self, action: #selector(tripleFriendCell.handleActionButton1), for: .touchUpInside)
        secondFriendButton.addTarget(self, action: #selector(tripleFriendCell.handleActionButton2), for: .touchUpInside)
        thirdFriendButton.addTarget(self, action: #selector(tripleFriendCell.handleActionButton3), for: .touchUpInside)
        
        firstFriendButton.addTarget(self, action: #selector(tripleFriendCell.firstPicTapped), for: .touchDown)
        secondFriendButton.addTarget(self, action: #selector(tripleFriendCell.secondPicTapped), for: .touchDown)
        thirdFriendButton.addTarget(self, action: #selector(tripleFriendCell.thirdPicTapped), for: .touchDown)
        
    }
    
    func presetButton(button: UIButton){
        //TODO: add alpha = 0 which will be animated when pictures are ready
        button.backgroundColor = UIColor.white
        button.layer.borderColor = self.standardColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 90/2
        button.clipsToBounds = true
        button.titleLabel?.text = ""
        button.contentMode = .scaleAspectFit
        
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        presetButton(button: firstFriendButton)
        presetButton(button: secondFriendButton)
        presetButton(button: thirdFriendButton)
        
        
    }
    
    func presetButton2(button: UIButton){
        //TODO: add alpha = 0 which will be animated when pictures are ready
        button.backgroundColor = UIColor.black
        button.layer.borderColor = self.standardColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 90/2
        button.clipsToBounds = true
        button.titleLabel?.text = ""
        button.imageView?.contentMode = .scaleAspectFill
        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateButton(button: UIButton, friend: facebookFriend){
        button.layer.borderColor = friend.selected ? tapColor : standardColor
        button.alpha = 1
        button.setImage(friend.profilePicture, for: .normal)
    }
    
    
    func updateFriendsCell1(friend1: facebookFriend){
        updateButton(button: firstFriendButton,friend: friend1)
        secondFriendButton.alpha = 0
        thirdFriendButton.alpha = 0
        friendsInCell = [friend1]
        
    }
    
    
    func updatetripleFriendCell(friend1: facebookFriend, friend2: facebookFriend){
        updateButton(button: firstFriendButton,friend: friend1)
        updateButton(button: secondFriendButton, friend: friend2)
        thirdFriendButton.alpha = 0
        friendsInCell = [friend1,friend2]
    }
    
    func updateFriendsCell3(friend1: facebookFriend, friend2: facebookFriend, friend3: facebookFriend){
        updateButton(button: firstFriendButton,friend: friend1)
        updateButton(button: secondFriendButton, friend: friend2)
        updateButton(button: thirdFriendButton, friend: friend3)
        friendsInCell = [friend1,friend2,friend3]
    }
    
    func handleActionButton1(){
        firstFriendButton.layer.borderColor = (firstFriendButton.layer.borderColor == standardColor ) ? standardColor : tapColor
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
    
    func handleActionButton2(){
        firstFriendButton.layer.borderColor = (firstFriendButton.layer.borderColor == standardColor ) ? standardColor : tapColor
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
    
    func handleActionButton3(){
        firstFriendButton.layer.borderColor = (firstFriendButton.layer.borderColor == standardColor ) ? standardColor : tapColor
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
    
    func firstPicTapped(_ sender: AnyObject) {
        firstFriendButton.layer.borderColor = (firstFriendButton.layer.borderColor == standardColor ) ? tapColor : standardColor
    }
    func secondPicTapped(_ sender: AnyObject) {
        secondFriendButton.layer.borderColor = (secondFriendButton.layer.borderColor == standardColor ) ? tapColor : standardColor
    }
    
    func thirdPicTapped(_ sender: AnyObject) {
        thirdFriendButton.layer.borderColor = (thirdFriendButton.layer.borderColor == standardColor ) ? tapColor : standardColor
    }
    
   
    

    

}
