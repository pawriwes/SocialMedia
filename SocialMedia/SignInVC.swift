//
//  ViewController.swift
//  SocialMedia
//
//  Created by Parivesh Sharma on 1/7/17.
//  Copyright © 2017 Parivesh Sharma. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: self)
        }

    }

    @IBAction func fbBtnTapped(_ sender: Any) {
        let fbLogin = FBSDKLoginManager()
        
        fbLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("unable to authenticate with Facebook - \(error)")
            }else if result?.isCancelled == true {
                print("User cancelled facebook authentication")
            }else {
                print("Sucessfully loged in to FaceBook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(using:credential)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func firebaseAuth(using credential:FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
            if let error = error {
                print("Unable to authenticate with Firebase - \(error)")
                return
            }
            print("Sucessfully Authenticated with Firebase")
            if let user = user {
                self.completeSignIn(userId: user.uid)
            }
        }
        }

    @IBAction func singInTapped(_ sender: Any) {
        if let email = emailField.text, let pwd = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("Firebase Success, signIn with email-pwd - \(error) ")
                    if let user = user {
                        self.completeSignIn(userId: user.uid)
                    }
                }else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("Firebase Error: unable to create user using email - \(error)")
                        }else {
                            print("Firebase SUccessfully user created")
                            if let user = user {
                                self.completeSignIn(userId: user.uid)
                            }
                        }
                    })
                }
            })
        }
    }
    func completeSignIn(userId:String){
        KeychainWrapper.standard.set(userId, forKey: KEY_UID)
        performSegue(withIdentifier: "goToFeed", sender: self)
    }
}

