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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.delegate = self
        titleField.attributedPlaceholder = NSAttributedString(string:"Title",
                                                               attributes:[NSForegroundColorAttributeName: UIColor.white])
        titleField.becomeFirstResponder()
        titleField.autocapitalizationType = .sentences
        titleField.frame = CGRect(x: 0, y: UIScreen.main.bounds.height/2-titleField.frame.height/2, width: UIScreen.main.bounds.width, height: titleField.frame.height)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nameAndDescription.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        
    }

    func dismissKeyboard(){
        self.view.endEditing(true)
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
