//
//  ViewController.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 27/09/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FBSDKLoginKit
import FirebaseAuth
import FirebaseStorage

class LoginVC: UIViewController {
    
    @IBOutlet weak var facebookLoginBtnLabel: UIButton!
    @IBOutlet weak var aivControl: UIActivityIndicatorView!
    @IBOutlet weak var slogan: UILabel!
    
    var myRootRef = FIRDatabase.database().reference()
    
    // Get a reference to the storage service, using the default Firebase App
    let storage = FIRStorage.storage()

    @IBOutlet weak var loginText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLoginBtnLabel.alpha = 0
        loginText.alpha = 0
        slogan.alpha = 0
        
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseIn, animations: {
            self.slogan.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 2, delay: 1.5, options: .curveEaseIn, animations: {
            self.facebookLoginBtnLabel.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 2, delay: 3, options: .curveEaseIn, animations: {
            self.facebookLoginBtnLabel.alpha = 1
            self.loginText.alpha = 1
        }, completion: nil)

        
        //TODO: add if user is already logged in
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if user != nil && FBSDKAccessToken.current() != nil  {
                //user is signed in 
                
                if let firebaseID = FIRAuth.auth()?.currentUser?.uid{
                    let facebookID = FBSDKAccessToken.current().userID!
                    let childUpdates = ["firebaseUser/\(firebaseID)": ["facebookID": "\(facebookID)"],"facebookUser/\(facebookID)":["firebaseID":firebaseID]]
                    
                    
                    self.myRootRef.updateChildValues(childUpdates)
                }
                
                
                
                
                
                
                //check if profile picture is in database, otherwise download
                let storageRef = self.storage.reference(forURL: "gs://testeventapp-cd7d2.appspot.com")
                
                let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                var docs: String = paths[0]
                let fullPath =  "\(docs)/profilePicture.jpg"
                
                let image    = UIImage(contentsOfFile: "\(fullPath)")
                
                if image == nil{
                
                do{
                    let urlString = "https://graph.facebook.com/\(FBSDKAccessToken.current().userID!)/picture?width=1000"
                    let url = URL(string: urlString)
                    DispatchQueue.global().async {
                        do {
                            print(url)
                            let data = try NSData(contentsOf: url!)
                            let proPic: UIImage! = UIImage(data: data! as Data)
                            let imageData = NSData(data:UIImagePNGRepresentation(proPic)!)
                            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                            var docs: String = paths[0] as! String
                            let fullPath =  "\(docs)/profilePicture.jpg"
                            print(fullPath)
                            let result = imageData.write(toFile: fullPath, atomically: true)
                            
                            DispatchQueue.global().sync {
                                let riversRef = storageRef.child("images/\((FIRAuth.auth()?.currentUser?.uid)!)/profilePicture.jpg")
                                riversRef.put(data as! Data, metadata: nil) { metadata, error in
                                    if (error != nil) {
                                        // Uh-oh, an error occurred!
                                    } else {
                                        // Metadata contains file metadata such as size, content-type, and download URL.
                                        //let downloadURL = metadata!.downloadURL
                                    }
                                }
                                
                            }
                        } catch {
                            print("error while getting picture")
                        }
                    }

                } catch{
                    //make picture
                }
                
                }else {
                        //picture is already in place
                    }
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let feedAndGroupVC: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "feedAndGroup")
                self.present(feedAndGroupVC, animated: true, completion: nil)
                self.aivControl.stopAnimating()

            } else {
                //user is not signed in
                
            }
        })
        
        // Do any additional setup after loading the view, typically from a nib.
        // Optional: Place the button in the center of your view.
        
        
        
     
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    

    
    //specialized function
    
    @IBAction func facebookLoginButton(_ sender: AnyObject) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["public_profile","email","user_friends"], from: self, handler: {
            (result,error) in
            if error != nil {
                print(error.debugDescription)
            } else if (result?.isCancelled)! {
                print("cancelled")
            } else {
                print("logged in to facebook")
                self.facebookLoginBtnLabel.alpha = 0
                self.loginText.alpha = 0
                self.aivControl.startAnimating()
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                FIRAuth.auth()?.signIn(with: credential, completion: {(user,error) in
                    if error != nil {
                        print(error.debugDescription)
                    } else {
                        print("firebase successful login")
                        
                        
                    }
                    self.aivControl.stopAnimating()
                })
                
                
            }
        })
    }
    
    
    
    
    


}

