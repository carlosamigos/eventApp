//
//  settingsVCViewController.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 30/09/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKCoreKit
import FirebaseStorage

class settingsVC: UIViewController {

    //TODO: make user able to adjust profile picture to own face
    
    @IBOutlet weak var profilePictureView: UIImageView!
    
    
    @IBOutlet weak var usersName: UILabel!
    
    
    @IBAction func signOutFromFBClicked(_ sender: AnyObject) {
        
        // sign out from firebase
        try! FIRAuth.auth()?.signOut()
        
        //sign out from facebook
        FBSDKAccessToken.setCurrent(nil)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let LoginVC: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "login")
        self.present(LoginVC, animated: true, completion: nil)
        
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        self.profilePictureView.layer.borderWidth = 3
        self.profilePictureView.layer.masksToBounds = false
        self.profilePictureView.layer.borderColor = UIColor.white.cgColor
        self.profilePictureView.layer.cornerRadius = self.profilePictureView.frame.size.height/2
        self.profilePictureView.clipsToBounds = true
        
        
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = FIRStorage.storage()
        let storageRef = storage.reference(forURL: "gs://testeventapp-cd7d2.appspot.com")
        
        
        print("loading image")
        
        
        
        
        
        
        if let user = FIRAuth.auth()?.currentUser {
            let name = user.displayName
            self.usersName.text = name

       
            if FBSDKAccessToken.current() != nil {
                
                let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                var docs: String = paths[0] as! String
                let fullPath =  "\(docs)/profilePicture.jpg"
                
                let image    = UIImage(contentsOfFile: "\(fullPath)")
                
                self.profilePictureView.image = image
                self.profilePictureView.contentMode = .scaleAspectFill
                
                if image == nil {
                let ref = storageRef.child("images/\((FIRAuth.auth()?.currentUser?.uid)!)/profilePicture.jpg")
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                ref.data(withMaxSize: 1 * 2024 * 2024) { (data, error) -> Void in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                    } else {
                        // Data for "images/island.jpg" is returned
                        let proPic: UIImage! = UIImage(data: data!)
                        self.profilePictureView.image = proPic
                        self.profilePictureView.contentMode = .scaleAspectFill
                    }
                }
                }
                
            }else {
                print("accesstoken is nil")
            }
            
            
           
        } else {
            print("user not authorised")
        }
    }
    
    func getDocumentsDirectory() -> String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return "\(documentsDirectory)"
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {});
    }

    

}
