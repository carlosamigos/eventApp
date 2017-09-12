//
//  groupsCustomCollectionCell.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 12/09/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//

import UIKit


class groupsCustomCollectionCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    let groupList = UITableView()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        groupList.delegate = self
        groupList.dataSource = self
        addSubview(groupList)
        globalFilteredGroups = globalGroupsFromFirebase
        groupList.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        groupList.keyboardDismissMode = .interactive
        groupList.register(groupCell.self, forCellReuseIdentifier: "groupCell")
        groupList.reloadData()
        groupList.separatorStyle = .none
        
    }
    
    //TODO: set size of table view
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalFilteredGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if let cell: groupCell = self.groupList.dequeueReusableCell(withIdentifier: "groupCell") as? groupCell {
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.textLabel?.text = globalFilteredGroups[indexPath.row].groupName
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    
}

