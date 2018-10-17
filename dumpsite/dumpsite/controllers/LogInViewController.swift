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
    var firestoredb: Firestore!
    var userCollection: CollectionReference!
    var userDocument: DocumentSnapshot!
    
    // Data Holders
    var userId: String!
    var isRememberMeOn: Bool!
    
    // Listener
    var handle: AuthStateDidChangeListenerHandle?
    
    // Indicators
    var activityIndicator: UIActivityIndicatorView!
    
    // Inherited Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get firestore reference
        getFirestoreDatabase()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop activity indicator
        stopActivityIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeNavigationBarTransparent()
        hideBackButton()
        handleTap()
        moveViewWithKeyboard()
    }
    
    // Make navigation bar transparent
    func makeNavigationBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    // Hides back button
    func hideBackButton() {
        self.navigationItem.leftItemsSupplementBackButton = false
        self.navigationItem.hidesBackButton = true
    }
    
    // Gets firstore reference and fixes date bug
    func getFirestoreDatabase() {
        // Get reference to Dumpsite's Firestore Database
        firestoredb = Firestore.firestore()
        
        // Avoid breaking the app cause by the change of behavior
        // of system Date objects
        let settings = firestoredb.settings
        settings.areTimestampsInSnapshotsEnabled = true
        firestoredb.settings = settings
    }
    
    // Signs in user
    @IBAction func signIn(_ sender: UIButton) {
        // Start activity indicator to show that something's happening
        showActivityIndicator()
        
        // Check if fields are empty
        guard let email = emailField.text, let password = passwordField.text else {
            // Show error on console
            print("Empty fields!")
            return
        }
        
        // Sign in user
        Auth.auth().signIn(withEmail: email, password: password) { (auth, err) in
            if let err = err {
                // Show message prompt when there's error
                print("Error signing in: \(err.localizedDescription)")
                
                // Show what's wrong to user though alert
                self.stopActivityIndicator() // Stop activity indicator
                
                // Create an alert
                let message = "The password you entered doesn't match the password in our records."
                let alert = UIAlertController(title: "Wrong Password", message: message, preferredStyle: .alert)
                alert.view.tintColor = UIColor.red
                alert.addAction(UIAlertAction(title: "I'll try again", style: .default, handler: nil))
                self.present(alert, animated: true)
                
            } else {
                // Check if auth object is not empty
                if let auth = auth {
                    // Update rememberMe field
                    self.updateUserSession(auth.user)
                    
                    // Check if email is verified. If not, prevent
                    // user from accessing the Feed View
                    if auth.user.isEmailVerified {
                        // Push to Feed View
                        self.performSegue(withIdentifier: "toFeedView", sender: nil)
                    } else {
                        // Show error on console
                        print("Email not yet verified.")
                        
                        // Show what's wrong to user though alert
                        self.stopActivityIndicator() // Stop activity indicator
                        
                        // Create an alert
                        let message = "In order to speed up your dumpsite's construction, verify your email first!"
                        let alert = UIAlertController(title: "Excited much?", message: message, preferredStyle: .alert)
                        alert.view.tintColor = UIColor.red
                        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                        self.present(alert, animated: true)
                        
                        // In here, we are just preventing the user from
                        // accessing a view but the truth is he is already
                        // signed in. Therefore, we must sign him out.
                        self.signOutUser()
                    }
                } else {
                    // For the mean time, ignore this.
                    // I dunno what if else is needed because will there
                    // be a time where auth is empty?
                }
            }
        }
    }
    
    // Determines whether application keeps user session or not
    @IBAction func rememberMeSwitch(_ sender: UISwitch) {
        isRememberMeOn = sender.isOn
        print("isUserSessionOn: \(isRememberMeOn!)")
    }
    
    // Updates the rememberMe of a user
    func updateUserSession(_ user: UserInfo) {
        // Create a reference to user document
        let userDocument = firestoredb.collection("users").document(user.uid)
        
        // Update rememberMe field in user document
        userDocument.updateData([
            "rememberMe": self.isRememberMeOn
        ]) { (err) in
            if let err = err {
                // Show error in console
                print("Error updating document: \(err.localizedDescription)")
            } else {
                // Show message on console
                print("Document updated successfully.")
            }
        }
    }
    
    // Sign out user and end his session
    func signOutUser() {
        // Just to be sure, check if there's a current user
        if let user = Auth.auth().currentUser {
            do {
                try Auth.auth().signOut()
                print("Signing out user \(user.uid)")
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
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
    
    // Show activty inidicator
    func showActivityIndicator() {
        // Initialize activity indicator
        activityIndicator = UIActivityIndicatorView()
        
        // Set properties
        let viewMaxY = view.frame.maxY
        let indicatorYPos = viewMaxY - 60
        activityIndicator.center = CGPoint(x: self.view.center.x, y: indicatorYPos)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        view.addSubview(activityIndicator)
        
        // Display activity indicator
        activityIndicator.startAnimating()
    }
    
    // Stop activity indicator
    func stopActivityIndicator() {
        // Check first if activity indicator is empty
        if let activityIndicator = self.activityIndicator {
            activityIndicator.stopAnimating()
        }
    }
}

