//
//  groupCellFeed.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 12/09/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//

import UIKit

class feedGroupCell: UITableViewCell {
    
    let standardColor = UIColor.white.cgColor
    let tapColor = constants.globalColors.happyMainColor.cgColor
    var groupPicture = UIImageView()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style,reuseIdentifier: reuseIdentifier)
        setupImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupImage(){
        let screenSize: CGRect = UIScreen.main.bounds
        let totalWidth = screenSize.width //TODO: make dynamic. Also know that cellHeight = 110
        let imageSize: CGFloat = 90.0
        let cellHeight: CGFloat = 110.0
        
        groupPicture = UIImageView(frame: CGRect(x: 1/4*(3*totalWidth-imageSize), y: cellHeight/2-imageSize/2, width: imageSize, height: imageSize))
        presetImage(image: groupPicture)
        addSubview(groupPicture)
        
        
    }
    
    func presetImage(image: UIImageView){
        //TODO: add alpha = 0 which will be animated when pictures are ready
        image.backgroundColor = constants.globalColors.happyMainColor
        image.layer.borderColor =  self.standardColor
        image.layer.borderWidth = 3
        image.layer.cornerRadius = 90.0/2
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        presetImage(image: groupPicture)
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    
    
    
}
