//
//  LogInViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 04/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {
    
    // Tag Views
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var btnLogIn: UIButton!
    @IBOutlet var switchRememberMe: UISwitch!
    
    
    // References
    var db: Firestore!
    var userCollection: CollectionReference!
    var userDocument: DocumentSnapshot!
    
    // Data Holders
    var userId: String!
    var isRememberMeOn: Bool!
    
    // Listener
    var handle: AuthStateDidChangeListenerHandle?
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeNavigationBarTransparent()
        hideBackButton()
        handleTap()
        moveViewWithKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get firestore reference
        getFirestoreDatabase()
        getCurrentUser()
    }
    
    func makeNavigationBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func hideBackButton() {
        self.navigationItem.leftItemsSupplementBackButton = false
        self.navigationItem.hidesBackButton = true
    }
    
    // Gets firstore reference and fixes date bug
    func getFirestoreDatabase() {
        // Get reference to Dumpsite's Firestore Database
        db = Firestore.firestore()
        
        // Avoid breaking the app cause by the change of behavior
        // of system Date objects
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    // Signs in user
    @IBAction func signIn(_ sender: UIButton) {
        // Check if fields are empty
        guard let email = emailField.text, let password = passwordField.text else {
            print("Empty fields!")
            return
        }
        
        // Before signing in check if user wants to keep his session
        
        
        // Sign in user
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if let err = err {
                // Show message prompt when there's error
                print("Error signing in: \(err.localizedDescription)")
            } else {
                // Check if user trying to log in is the current user
                if let user = Auth.auth().currentUser {
                    // Check if email is verified
                    if !user.isEmailVerified {
                        // Show message prompt
                        print("Email not yet verified")
                    } else {
                        // Push to Feed View
                        self.performSegue(withIdentifier: "toFeedView", sender: nil)
                    }
                } else {
                    // Show message prompt
                    print("Not current user!")
                }
            }
        }
    }
    
    // Determines whether application keeps user session or not
    @IBAction func rememberMeSwitch(_ sender: UISwitch) {
        isRememberMeOn = sender.isOn
    }
    
    func getCurrentUser() {
        // Create a state listener
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            // Check if user has a value
            if let user = user {
                if user == auth.currentUser {
                    // Check if email is verified
                    if !user.isEmailVerified {
                        // Show message prompt
                        print("Email not yet verified.")
                    } else {
                        // Push to Feed View
                        self.performSegue(withIdentifier: "toFeedView", sender: nil)
                    }
                }
            }
            else {
                // Show message prompt
                print("There's no current user!")
            }
        }
    }
    
    // Miscs
    // Dismiss keyboard when users tap anywhere
    func handleTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Push view up when keyboard is obscuring textfield
    func moveViewWithKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 100
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height - 100
            }
        }
    }
}

