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

class eventChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var inputTextField: UITextField!
    var event: eventInformation!
    var messageTable: UITableView!

    let cellId = "cellId"
    let numberOfCharactersPerLine = CGFloat(80.0)
    let messageHeightPerLine = CGFloat(50.0)
    let spaceFromSide = CGFloat(5.0)
    let personalColor = UIColor(red: 0, green: 137.0/256, blue: 249.0/256, alpha: 1)
    let otherColor = UIColor.lightGray

    override func viewDidLoad() {
        super.viewDidLoad()
        setupComponents()
    }
    
    func setupComponents(){
        event.addChatListener(listener: self)
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
        view.addSubview(messageTable)
        view.sendSubview(toBack: messageTable)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event.messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row >= event.messages.count){
            return messageHeightPerLine
        } else {
            let text = event.messages[indexPath.row].text
            return heightOfMessageBubble(string: text!)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTable.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let text = event.messages[indexPath.row].text
        let textField = VerticallyCenteredTextView(frame: CGRect(x: spaceFromSide, y: spaceFromSide, width: UIScreen.main.bounds.width-10, height: heightOfMessageBubble(string: text!)-spaceFromSide*CGFloat(2.0)))
        
        textField.text = text
        textField.font = textField.font!.withSize(20)
        textField.textAlignment = (FIRAuth.auth()?.currentUser?.uid==event.creatorID ? .right : .left)
        cell.addSubview(textField)
        textField.clipsToBounds = true
        textField.layer.cornerRadius = CGFloat(10)
        textField.backgroundColor = (FIRAuth.auth()?.currentUser?.uid==event.creatorID ? personalColor : otherColor)
        textField.textColor = UIColor.white
        return cell
    }
    
    func heightOfMessageBubble(string: String) -> CGFloat{
        let length = CGFloat(string.characters.count)
        let height = (length/numberOfCharactersPerLine + 1.0)*messageHeightPerLine
        return height
    }

    
    func handleSendButton(){
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long        
        let eventId = event.eventID
        let userId = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference().child("eventMessages").child(eventId!).childByAutoId()
        var values = ["text": inputTextField.text!]
        values["time"] = formatter.string(from: currentDateTime)
        values["userId"] = userId
        ref.updateChildValues(values)
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
        }
    }
}
