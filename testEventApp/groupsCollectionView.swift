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
    
    weak var delegate : groupsCustomCollectionCellDelegate?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        groups.delegate = self
        groups.dataSource = self
        addSubview(groups)
        groups.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        groups.keyboardDismissMode = .interactive
        
        groups.register(feedGroupCell.self, forCellReuseIdentifier: "feedGroupCell")
        
        groups.reloadData()
        
        groups.separatorStyle = .none
        
    }
    
    //TODO: set size of table view
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didClick(collectionCell: self, groupCell: groups.cellForRow(at: indexPath) as! feedGroupCell)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if let cell: feedGroupCell = self.groups.dequeueReusableCell(withIdentifier: "feedGroupCell") as? feedGroupCell {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.textLabel?.text = globalGroups[indexPath.row]
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    
}

