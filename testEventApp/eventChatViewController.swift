//
//  eventChatViewController.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 14/09/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

let offlineMode = false
var offlineMessageList = [String]()

class eventChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var inputTextField: UITextField!
    var event: eventInformation!
    var messageTable: UITableView!
    var messageCurtain: UIView!
    var messagesText: VerticallyCenteredTextView!
    
    let cellId = "cellId"
    let numberOfCharactersPerLine = 65
    let heighOfTopView = 76
    let messageHeightPerLine = CGFloat(55)
    let spaceFromTableViewCellEdges = CGFloat(5)
    let bubbleEdgeSpace = CGFloat(80)
    let personalColor = UIColor(red: 0, green: 137.0/256, blue: 249.0/256, alpha: 1)
    let otherColor = UIColor(red:0.93, green: 0.93, blue: 0.93, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
        messageTable.contentInset = UIEdgeInsets(top: messagesText.frame.height + 8, left: 0, bottom: 58, right: 0)
        messageTable.scrollIndicatorInsets = UIEdgeInsets(top: messagesText.frame.height + 8, left: 0, bottom: 58, right: 0)
        messageTable.scrollRectToVisible(CGRect(x: 0, y: messageTable.contentSize.height - messageTable.bounds.size.height, width: messageTable.bounds.size.width, height: messageTable.bounds.size.height), animated: true)
    }
    
    func setupComponents(){
//        if(!offlineMode){
//            event.addChatListener(listener: self)
//        }
        let bottomContainerView = UIView()
        bottomContainerView.backgroundColor = UIColor.white
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomContainerView)
        bottomContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        bottomContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0.0).isActive = true
        bottomContainerView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: bottomContainerView.rightAnchor, constant: 0.0).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor, constant: 0.0).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        sendButton.heightAnchor.constraint(equalTo: bottomContainerView.heightAnchor, constant: 0.0).isActive = true
        sendButton.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        
        inputTextField = UITextField()
        inputTextField.delegate = self 
        inputTextField.placeholder = "Enter message"
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: bottomContainerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor, constant: 0.0).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: 0.0).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: bottomContainerView.heightAnchor, constant: 0.0).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor(red: 220.0/256.0, green: 220.0/256.0, blue: 220.0/256.0, alpha: 1.0)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.addSubview(seperatorLineView)
        
        seperatorLineView.leftAnchor.constraint(equalTo: bottomContainerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: bottomContainerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: bottomContainerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        messageTable = UITableView()
        messageTable.separatorColor = UIColor.clear
        messageTable.delegate = self
        messageTable.dataSource = self
        messageTable.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        messageTable.backgroundColor = UIColor.white
        messageTable.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-bottomContainerView.frame.height)
        messageTable.contentInset = UIEdgeInsetsMake(8, 0, 55, 0)
        messageTable.allowsSelection = false
        

        view.addSubview(messageTable)
        view.sendSubview(toBack: messageTable)
        
        messageCurtain = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat(heighOfTopView)))
        messageCurtain.backgroundColor = UIColor.white
//        let mask = CAGradientLayer()
//        mask.frame = self.messageCurtain.frame
//        mask.startPoint = CGPoint(x: 0.0, y: 0.0)
//        mask.endPoint = CGPoint(x: 0.0, y: 1.0)
//        mask.locations = [ (0.0), (0.7),(0.9), (1.0)]
//        mask.colors = [ UIColor(white: 1.0,alpha: 1.0).cgColor, UIColor(white: 1.0,alpha: 0.7).cgColor, UIColor(white: 1.0,alpha: 0.3).cgColor , UIColor(white: 1.0, alpha: 0.0).cgColor]
//        self.messageCurtain.layer.addSublayer(mask)
    
        messagesText = VerticallyCenteredTextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat(heighOfTopView)))
        messagesText.text = "Messages"
        messagesText.font = messagesText.font!.withSize(18)
        messagesText.textAlignment = .center
        messagesText.textColor = personalColor
        messagesText.isUserInteractionEnabled = false
        messageCurtain.addSubview(messagesText)
        messagesText.backgroundColor = UIColor.clear
//        UIApplication.shared.keyWindow?.addSubview(messagesText)
//        self.view.bringSubview(toFront: messagesText)
        
        
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        view.addSubview(messageCurtain)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if(messageTable.contentOffset.y < 0 && !shouldExit){
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame.origin = CGPoint(x: 0, y: 0 )
                self.view.backgroundColor = UIColor(white: 1.0, alpha:1.0)
            })
        }
    }

    var shouldExit = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(messageTable.contentOffset.y < 0){
            self.view.frame.origin = CGPoint(x: 0, y: -min(messageTable.contentOffset.y, 0) )
            let pointOfDismiss = -100
            self.view.backgroundColor = UIColor(white: 1.0, alpha: (1.0-messageTable.contentOffset.y/CGFloat(pointOfDismiss)))
            if(messageTable.contentOffset.y < -100){
                shouldExit = true
                self.view.backgroundColor = UIColor(white: 1.0, alpha:0.0)
                messageTable.endUpdates()
                messageTable.isUserInteractionEnabled = false
                dismiss(animated: true, completion: nil)
            }
        } else {
            self.view.frame.origin = CGPoint(x: 0, y: 0 )
            self.view.backgroundColor = UIColor(white: 1.0, alpha:1.0)
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(offlineMode){
            return offlineMessageList.count
        }
        return event.messages.count
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16.0)], context: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var text: String?
        if(offlineMode){
            text = offlineMessageList[indexPath.row]
        }else {
            text = event.messages[indexPath.row].text
        }
        var height = estimateFrameForText(text: text!).height + 20
        return CGFloat(height + 10)
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var text: String?
        if(offlineMode){
            text = offlineMessageList[indexPath.row]
        }else {
            text = event.messages[indexPath.row].text
        }
        
    
        var isPersonal: Bool!
        let senderId = event.messages[indexPath.row].senderId
        if(offlineMode){
            isPersonal = true
        } else {
            isPersonal = (Auth.auth().currentUser?.uid==senderId)
        }
        
        let messageCell = ChatMessageCell()
        var width = estimateFrameForText(text: text!).width
        var height = estimateFrameForText(text: text!).height + 20
        messageCell.bubbleWidthAnchor?.constant = width + 32
        
        messageCell.frame = CGRect(x: 0, y: CGFloat(0), width: width, height: height)
        messageCell.textView.text = text
        messageCell.bubbleView.backgroundColor = isPersonal ? constants.globalColors.happyMainColor : constants.globalColors.greyMessageBubbleColor
        messageCell.textView.textColor = isPersonal ? UIColor.white : .black
        
        let tableViewCell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height + CGFloat(40)))
        tableViewCell.addSubview(messageCell)
        
        if(!isPersonal){
            //fix picture
            let facebookId = firebaseIDtoFacebookID[senderId!]
            let friend = facebookIDtoFacebookFriendMap[facebookId!]
            messageCell.profileImageView.image = friend!.profilePicture
            messageCell.bubbleViewRightAnchor?.isActive = false
            messageCell.bubbleViewLeftAnchor?.isActive = true
            messageCell.profileImageView.isHidden = false
        } else {
            messageCell.profileImageView.isHidden = true
            messageCell.frame = CGRect(x: UIScreen.main.bounds.width - width, y: CGFloat(0), width: width, height: height)
            
        }
        
        return tableViewCell
    }
    

    
    func handleSendButton(){
        let currentDateTime = Date()
        if(inputTextField.text!.count == 0){
            return
        }
        
        if(offlineMode){
            offlineMessageList.append(inputTextField.text!)
            self.messageTable.reloadData()
            messageTable.scrollToRow(at: IndexPath(row: messageTable.numberOfRows(inSection: 0)-1, section: 0), at: .bottom, animated: true)
            
            return
        }
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long        
        let eventId = event.eventID
        let userId = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("eventMessages").child(eventId!).childByAutoId()
        var values = ["text": inputTextField.text!]
        values["time"] = formatter.string(from: currentDateTime)
        values["userId"] = userId
        ref.updateChildValues(values)
        inputTextField.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendButton()
        textField.text = ""
        return true
    }
}


class VerticallyCenteredTextView: UITextView {
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
            self.textAlignment = .left
        }
    }
}
