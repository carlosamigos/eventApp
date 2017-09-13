//
//  nameAndDescription.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 03/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit

class nameAndDescription: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleField: UITextField!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.delegate = self
        titleField.attributedPlaceholder = NSAttributedString(string:"Title",
                                                               attributes:[NSForegroundColorAttributeName: UIColor.white])
        titleField.becomeFirstResponder()
        titleField.autocapitalizationType = .sentences
        titleField.frame = CGRect(x: 0, y: UIScreen.main.bounds.height/2-titleField.frame.height/2, width: UIScreen.main.bounds.width, height: titleField.frame.height)
        titleField.returnKeyType = UIReturnKeyType.done
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draggablePanGestureAction))
        self.view.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    func draggablePanGestureAction(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        view.frame.origin = CGPoint(x: 0, y: max(translation.y, 0) )
        view.endEditing(true)
        if(translation.y > UIScreen.main.bounds.height * constants.gestureConstants.getureRemoveThreshold){
            view.removeGestureRecognizer(self.panGestureRecognizer)
            backBtnPressed(self)
        } else {
            let velocity = gesture.velocity(in: view)
            if gesture.state == .ended{
                if velocity.y >= constants.gestureConstants.gestureRemoveViewSpeed {
                    view.removeGestureRecognizer(self.panGestureRecognizer)
                    backBtnPressed(self)
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


    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.view.endEditing(true)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldPrimaryActionTriggered(_ sender: AnyObject) {
        performSegue(withIdentifier: "toWeekday", sender: titleField.text!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondVC: chooseDay = segue.destination as! chooseDay
        secondVC.eventTitle = sender as! String
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.utf16.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 15
    }
    
    
    
    

   

}
