//
//  tripleFriendCell.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 09/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit

class groupCell: UITableViewCell {
    
    
    
    var groupInformation: groupInformation!
    let standardColor = UIColor.white.cgColor
    let tapColor = constants.globalColors.happyMainColor.cgColor
    var groupPicture = UIButton()

    
    
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
        let cellHeight: CGFloat = 110.0
        
        
        
        groupPicture = UIButton(frame: CGRect(x: 1/4*(3*totalWidth-imageSize), y: cellHeight/2-imageSize/2, width: imageSize, height: imageSize))
        presetButton(button: groupPicture)
        addSubview(groupPicture)
        
        
//        groupPicture.addTarget(self, action: #selector(groupCell.handleActionButton), for: .touchUpInside)
        
        groupPicture.addTarget(self, action: #selector(groupCell.groupPictureTapped), for: .touchDown)
        
        
    }
    
    func presetButton(button: UIButton){
        //TODO: add alpha = 0 which will be animated when pictures are ready
        button.backgroundColor = UIColor.blue//UIColor.white
        button.layer.borderColor =  self.standardColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 90.0/2
        button.clipsToBounds = true
        button.titleLabel?.text = ""
        button.contentMode = .scaleAspectFill
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        presetButton(button: groupPicture)
  
    }
    
  
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateButton(button: UIButton){//, friend: facebookFriend){
        //button.layer.borderColor = groupPicture.isSelected ? tapColor : standardColor
        button.alpha = 1
        //button.setImage(friend.profilePicture, for: .normal)
    }
    

    

    
    func handleActionButton(){
        
        
    }
    

    
    func groupPictureTapped(_ sender: AnyObject) {
        if(groupPicture.layer.borderColor == standardColor ){
            selectedGroups.append(groupInformation)
            groupPicture.layer.borderColor = tapColor
        }else {
            if let index = selectedGroups.index(where: { (item) -> Bool in
                item.groupId == groupInformation.groupId
            }){
                selectedGroups.remove(at: index )
            }
            
            groupPicture.layer.borderColor = standardColor
        }
    }
    

    
}
