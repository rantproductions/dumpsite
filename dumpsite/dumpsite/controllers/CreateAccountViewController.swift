//
//  CreateAccountViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 04/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {

    // Tag Views
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    // Firestore References
    var db: Firestore!
    var userDefaultsRef: DocumentReference!
    
    // Data Holders
    var defaultKeys = [String: Any]()
    var trashcanCount: Int!
    var trashcans: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeNavigationBarTransparent()
        hideBackButton()
        handleTap()
        moveViewWithKeyboard()
        
        // Get firestore reference
        getFirestoreDatabase()
        getDefaultUserValues()
    }

    // Makes navbar transparent
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
        db = Firestore.firestore()
        
        // Avoid breaking the app cause by the change of behavior
        // of system Date objects
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    
    // Gets user default values from database
    func getDefaultUserValues() {
        // Get reference to user document in defaults collection
        userDefaultsRef = db.collection("defaults").document("user")
        
        // Get trashcan count and list of trashcans
        // By default, a dumpsite has one trashcan upon construction
        var userDefaults = [String: Any]()
        userDefaultsRef.getDocument() { (document, err) in
            // Check for errors
            if let err = err {
                // Show message prompt when there's an error
                print("Error getting user defaults: \(err.localizedDescription)")
            } else {
                // Check if document is not empty
                if let document = document, document.exists {
                    for data in document.data()! {
                        userDefaults[data.key] = data.value
                    }
                    self.trashcanCount = userDefaults["trashcanCount"] as? Int
                    self.trashcans = userDefaults["trashcans"] as? [String]
                } else {
                    print("Document does not exist!")
                }
            }
        }
    }
    
    // Creates a user document
    func createAUserDocument(userId: String, email: String, password: String) {
        // Get default values and create user
        let newUser = User(userId: userId, email: email, password: password, trashcanCount: trashcanCount, trashcans: trashcans)
        
        // Add new user document to users collection
        // Set merge to true to avoid overwriting if document exists
        db.collection("users").document(newUser.dictionary["userId"] as! String).setData(newUser.dictionary, merge: true) { err in
            // Check for errors
            if let err = err {
                print("Error appending new user in collection: \(err.localizedDescription)")
            } else {
                print("New user created.")
            }
        }
    }
    
    // Uses regex to validate an Email Address
    func validateEmail(email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    
    func sendEmailVerification () {
        Auth.auth().currentUser?.sendEmailVerification() { (err) in
            // Check for errors
            if let err = err {
                print("Error sending email verification: \(err.localizedDescription)")
            } else {
                // Push another view to show message
                self.performSegue(withIdentifier: "dumpsiteConstruction", sender: self) // temporary
            }
        }
    }

    @IBAction func constructDumpsite(_ sender: UIButton) {
        // Check first if fields are empty
        guard let email = emailField.text, let password = passwordField.text else {
            print("An email and a password wouldn't hurt, right?")
            return
        }
        
        // Then see if email address if valid
        if validateEmail(email: email) {
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, err) in
                // Check for errors
                if let err = err {
                    print("Error creating new user: \(err.localizedDescription)")
                } else {
                    // Create a user document
                    if let authResult = authResult { // Check if there's a user created
                        // Use uid given by firebase to every user created
                        self.createAUserDocument(userId: authResult.user.uid, email: email, password: password)
                        
                        // Send email verification
                        self.sendEmailVerification()
                    } else {
                        print("No user was created.")
                    }
                }
            }
        } else {
            print("Email address is not valid")
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
                print("=0")
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                print("!=0")
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}
