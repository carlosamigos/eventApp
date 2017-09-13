//
//  createNewGroup.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 24/08/2017.
//  Copyright © 2017 CarlTesting. All rights reserved.
//

import Foundation
import UIKit

class createNewGroupName : UIViewController, UITextFieldDelegate {
    
    var titleField: UITextField!
    var backButton: UIButton!
    var panGestureRecognizer: UIPanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTitleField()
        prepareBackButton()
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draggablePanGestureAction))
        self.view.addGestureRecognizer(panGestureRecognizer)
    
    }
    
    func prepareBackButton(){
        //backbutton
        backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 67, height: 67))
        backButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 39)
        backButton.setTitle("-", for: .normal)
        self.backButton.isUserInteractionEnabled = true
        self.backButton.addTarget(self, action: #selector(createNewGroupName.handleActionBackButton), for: .touchUpInside)
        self.view.addSubview(self.backButton)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performSegue(withIdentifier: "segueFromGroupNameToGroupFriends", sender: titleField.text!)
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondVC: selectFriendsToGroup = segue.destination as! selectFriendsToGroup
        secondVC.nameOfGroup = sender as! String
    }
    

    func draggablePanGestureAction(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        view.frame.origin = CGPoint(x: 0, y: max(translation.y, 0) )
        if(translation.y > UIScreen.main.bounds.height * constants.gestureConstants.getureRemoveThreshold){
            view.removeGestureRecognizer(self.panGestureRecognizer)
            handleActionBackButton()
        } else {
            let velocity = gesture.velocity(in: view)
            if gesture.state == .ended{
                if velocity.y >= constants.gestureConstants.gestureRemoveViewSpeed {
                    view.removeGestureRecognizer(self.panGestureRecognizer)
                    handleActionBackButton()
                }
                else{
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.frame.origin = CGPoint(x: 0, y: 0)
                    })
                    titleField.becomeFirstResponder()
                }
            }
        }
    }
    
    
    func handleActionBackButton(){
        self.view.endEditing(true)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        dismiss(animated: true, completion: nil)
    }
    
    func prepareTitleField(){
        titleField = UITextField()
        self.view.addSubview(titleField)
        titleField.delegate = self
        titleField.textColor = UIColor.white
        titleField.attributedPlaceholder = NSAttributedString(string:"Group name",
                                                              attributes:[NSForegroundColorAttributeName: UIColor.white])
        titleField.font = UIFont(name: (titleField.font!).fontName, size: 22)
        titleField.becomeFirstResponder()
        titleField.autocapitalizationType = .sentences
        titleField.frame = CGRect(x: UIScreen.main.bounds.width / 2 - UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height/2-100/2, width: UIScreen.main.bounds.width, height: 100)
        titleField.textAlignment = NSTextAlignment.center
        titleField.returnKeyType = UIReturnKeyType.done
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    


}
