//
//  segueFeedToEvent.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 05/11/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit

class segueFeedToEvent: UIStoryboardSegue {
    
    override func perform() {
        let sourceVC = self.source as! FeedAndGroupsViewController
        let destinationVC = self.destination as! eventInformationVC
        
        //MUST INCLUDE ADD CHILD VIEW CONTROLLER
        sourceVC.addChildViewController(destinationVC)
        sourceVC.view.addSubview(destinationVC.view)
        destinationVC.didMove(toParentViewController: sourceVC)
        
        destinationVC.profilePicture.alpha = 1.0
        destinationVC.view.backgroundColor = UIColor(white: 1, alpha: 0.0)
        destinationVC.eventPicture.alpha = 0
        destinationVC.eventTitle.sizeToFit()
        destinationVC.backButton.alpha = 0
        destinationVC.attendingCollectionView.alpha = 1
        destinationVC.eventsCustomCollectionCellRef = sourceVC.eventClassRef
        
//        destinationVC.messageImageView.alpha = 0
        sourceVC.latestEventCell.alpha = 0
        destinationVC.divider.frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY, width: UIScreen.main.bounds.width, height: destinationVC.dividerHeight)
        
        
        
        let newPicSizeMultiplier: CGFloat = 1.3
            
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
                
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            destinationVC.attendingCollectionView.frame = CGRect(x: destinationVC.attendingCollectionView.frame.minX, y: UIScreen.main.bounds.height-destinationVC.attendingButtonHeight, width: destinationVC.attendingCollectionView.frame.width, height: destinationVC.attendingCollectionView.frame.height)
            destinationVC.divider.frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY-destinationVC.attendingButtonHeight-destinationVC.dividerHeight, width: UIScreen.main.bounds.width, height: destinationVC.dividerHeight)
//            destinationVC.messageImageView.alpha = 1
            sourceVC.latestEventCollectionCell.events.alpha = 0
            destinationVC.view.backgroundColor = UIColor(white: 1, alpha: 1)
            destinationVC.eventPicture.alpha = 0.0
            destinationVC.profilePicture.frame = CGRect(x: UIScreen.main.bounds.width/2.0-destinationVC.profilePicture.frame.width/2, y: CGFloat(destinationVC.eventPictureHeight-Double(destinationVC.profilePicture.frame.height)/2), width: destinationVC.profilePicture.frame.width, height: destinationVC.profilePicture.frame.width)
            
            destinationVC.profilePicture.transform = CGAffineTransform(scaleX: newPicSizeMultiplier, y: newPicSizeMultiplier)
            
            
            destinationVC.eventTitle.frame = CGRect(x: UIScreen.main.bounds.width/2.0-destinationVC.eventTitle.frame.width/2, y: CGFloat(destinationVC.profilePicture.frame.maxY + destinationVC.distanceFromTitleToProfilePicture) , width: destinationVC.eventTitle.frame.width, height: destinationVC.eventTitle.frame.height)
            
            destinationVC.eventTime.frame = CGRect(x: UIScreen.main.bounds.width/2.0-destinationVC.eventTime.frame.width/2, y: CGFloat(destinationVC.eventTitle.frame.maxY + destinationVC.distanceFromTitleToProfilePicture) , width: destinationVC.eventTime.frame.width, height: destinationVC.eventTime.frame.height)
            
            destinationVC.backButton.alpha = 1
            
            
            let totalWidthOfAddressAndPin = destinationVC.address.frame.width
            
            
            destinationVC.address.frame = CGRect(x: UIScreen.main.bounds.width/2 - destinationVC.address.frame.width/2, y: destinationVC.eventTime.frame.maxY+destinationVC.distanceFromTitleToProfilePicture, width: destinationVC.address.frame.width, height: destinationVC.address.frame.height)
            destinationVC.address.sizeToFit()
            
            
            let totalWidthOfAttending = destinationVC.addressPin.frame.width + destinationVC.distanceFromTitleToProfilePicture + destinationVC.numberAttending.frame.width
            let distBetween = destinationVC.numberAttending.frame.minX - destinationVC.peoplePic.frame.maxX
                
            destinationVC.peoplePic.frame = CGRect(x: UIScreen.main.bounds.width/2-totalWidthOfAttending/2, y: destinationVC.address.frame.maxY+destinationVC.distanceFromTitleToProfilePicture+5, width: destinationVC.addressPin.frame.width, height: destinationVC.addressPin.frame.height)
            
            destinationVC.numberAttending.frame = CGRect(x: destinationVC.peoplePic.frame.maxX + destinationVC.distanceFromTitleToProfilePicture, y: destinationVC.peoplePic.frame.minY+1, width: destinationVC.numberAttending.frame.width, height: destinationVC.numberAttending.frame.height)
            
            if sourceVC.latestEventCell.eventInformation.attendingStatus == "IN" {
                destinationVC.attendingCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
            } else if sourceVC.latestEventCell.eventInformation.attendingStatus == "OUT" {
                destinationVC.attendingCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .left, animated: true)
            }
            
            }) { (finished) in
                
                
                
                
                
        }
        

        
    }

}
