//
//  refreshSelectedFriendsAndGroups.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 12/09/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//

import UIKit

func resetSelectedFriendsAndGroups(tripleFriendsClassRef: tripleFriendsCustomCollectionCell){
    
    //reset friends
    for cell in tripleFriendsClassRef.friendsList.visibleCells{
        let cell2 = (cell as! tripleFriendCell)
        if(cell2.friendsInCell.count == 1){
            if(cell2.firstFriendButton.layer.borderColor == constants.globalColors.happyMainColor.cgColor){
                cell2.firstFriendButton.sendActions(for: .touchUpInside)
            }
            
        } else if (cell2.friendsInCell.count == 2){
            if(cell2.firstFriendButton.layer.borderColor == constants.globalColors.happyMainColor.cgColor){
                cell2.firstFriendButton.sendActions(for: .touchUpInside)
            }
            if(cell2.secondFriendButton.layer.borderColor == constants.globalColors.happyMainColor.cgColor){
                cell2.secondFriendButton.sendActions(for: .touchUpInside)
            }
        } else {
            if(cell2.firstFriendButton.layer.borderColor == constants.globalColors.happyMainColor.cgColor){
                cell2.firstFriendButton.sendActions(for: .touchUpInside)
            }
            if(cell2.secondFriendButton.layer.borderColor == constants.globalColors.happyMainColor.cgColor){
                cell2.secondFriendButton.sendActions(for: .touchUpInside)
            }
            if(cell2.thirdFriendButton.layer.borderColor == constants.globalColors.happyMainColor.cgColor){
                cell2.thirdFriendButton.sendActions(for: .touchUpInside)
            }
        }
    }
    
    //TODO: reset groups
}
