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
    var firestoredb: Firestore!
    var userDefaultsRef: DocumentReference!
    
    // Data Holders
    var trashcanCount: Int!
    var trashcans: [String]!
    var rememberMe: Bool!
    
    var activityIndicator: UIActivityIndicatorView!
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop activity indicator
        stopActivityIndicator()
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
        firestoredb = Firestore.firestore()
        
        // Avoid breaking the app cause by the change of behavior
        // of system Date objects
        let settings = firestoredb.settings
        settings.areTimestampsInSnapshotsEnabled = true
        firestoredb.settings = settings
    }
    
    // Gets user default values from database
    func getDefaultUserValues() {
        // Get reference to user document in defaults collection
        userDefaultsRef = firestoredb.collection("defaults").document("user")
        
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
                    self.rememberMe = userDefaults["rememberMe"] as? Bool
                } else {
                    print("Document does not exist!")
                }
            }
        }
    }
    
    // Creates a user document
    func createAUserDocument(_ userId: String, _ email: String, _ password: String) {
        // Get default values and create user
        let newUser = User(userId: userId, email: email, password: password, rememberMe: rememberMe, trashcanCount: trashcanCount, trashcans: trashcans)
        
        // Add new user document to users collection
        // Set merge to true to avoid overwriting if document exists
        firestoredb.collection("users").document(newUser.dictionary["userId"] as! String).setData(newUser.dictionary, merge: true) { err in
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
    
    // Sends user a verfication link
    func sendEmailVerification () {
        Auth.auth().currentUser?.sendEmailVerification() { (err) in
            // Check for errors
            if let err = err {
                print("Error sending email verification: \(err.localizedDescription)")
            } else {
                // Push another view to show message
                self.performSegue(withIdentifier: "dumpsiteConstruction", sender: nil)
            }
        }
    }

    // Creates a user
    @IBAction func constructDumpsite(_ sender: UIButton) {
        // Start activity indicator to show that something is happening
        showActivityIndicator()
        
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
                        self.createAUserDocument(authResult.user.uid, email, password)
                        
                        // Send email verification to user
                        self.sendEmailVerification()
                    } else {
                        // Show error on console
                        print("No user was created.")
                    }
                }
            }
        } else {
            // Show error on console
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
                self.view.frame.origin.y -= keyboardSize.height - 150
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height - 150
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
        self.view.addSubview(activityIndicator)
        
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
