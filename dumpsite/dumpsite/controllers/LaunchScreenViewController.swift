//
//  LaunchScreenViewController.swift
//  dumpsite
//
//  This is where the application will check
//  if user wants to keep his session.
//  Even if user exits the app, Firebase keeps
//  the user's session until he signs out.
//
//  If user wants to keep his session,
//  push view to Feed View instead of Log In
//  view. If not, immediatley sign him out.
//
//  Created by Elisha Saylon on 10/17/18.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class LaunchScreenViewController: UIViewController {

    // Firestore References
    var firestoredb: Firestore!
    
    // Listeners
    var authStateListener: AuthStateDidChangeListenerHandle!
    
    // Data
    var numberOfPushes: Int = 0
    var activityIndicator: UIActivityIndicatorView!
    
    // Data for Next Views
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get firestore reference
        getFirestoreDatabase()
        getCurrentUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop activity indicator
        stopActivityIndicator()
        
        // Also, stop state listener
        Auth.auth().removeStateDidChangeListener(authStateListener)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Start activity indicator
        showActivityIndicator()
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
    
    // Gets current user if there is one
    func getCurrentUser() {
        // Create a listener that listens to authentication
        // changes in the application
        authStateListener = Auth.auth().addStateDidChangeListener() { (auth, user) in
            // Check if there's a current user
            if let user = user {
                // Show on console who's the current user
                print("Current User: \(user.uid)")
                
                // Check if user wants to keep his session
                self.checkUserSession(auth) { (isUserSessionOn) in
                    if isUserSessionOn {
                        // Check first if email is verified
                        if user.isEmailVerified {
                            // Push to Feed View
                            self.performSegue(withIdentifier: "launchToFeedView", sender: nil)
                        } else {
                            // Show message on console
                            print("Email is not yet verified.")
                            
                            // To avoid conflicts and errors
                            // log out the current user
                            self.signOutUser()
                            
                            // Then push to Log In View
                            if !self.isKind(of: LogInViewController.self) { // Prevents repeat of push
                                self.numberOfPushes += 1
                                if self.numberOfPushes == 1 {
                                    self.performSegue(withIdentifier: "toLogInView", sender: nil)
                                }
                            }
                        }
                    } else {
                        // Show message on console
                        print("User doesn't want to keep his session.")
                        
                        // Since user doesn't want to keep his session, end it by signing out
                        self.signOutUser()
                            // Can end session here, but there would be a problem.
                            // Since there is an authentication state listener,
                            // the functions will fire over again because there
                            // is a change of state which is signing out.
                            // Ergo, it is possible that pushing of views will repeat.
                        
                        // Then push to Log In View
                        if !self.isKind(of: LogInViewController.self) { // Prevents repeat of push
                            self.numberOfPushes += 1
                            if self.numberOfPushes == 1 {
                                self.performSegue(withIdentifier: "toLogInView", sender: nil)
                            }
                        }
                        
                    }
                }
            } else {
                // Show message on console
                print("There's no current user.")
                
                // Since there's no user, push to Log In View
                if !self.isKind(of: LogInViewController.self) { // Prevents repeat of push
                    self.numberOfPushes += 1
                    if self.numberOfPushes == 1 {
                        self.performSegue(withIdentifier: "toLogInView", sender: nil)
                    }
                }
            }
        }
    }
    
    // Check's if user wants to keep his session
    // even if he closes the application
    func checkUserSession(_ auth: Auth, completion: @escaping (_ isUserSessionOn: Bool)->()) {
        // Get current user from auth
        let user = auth.currentUser
        
        // Then create a reference to user's document
        // using user's uid
        let userDocument = firestoredb.collection("users").document((user?.uid)!)
        
        // Get the user document
        // Capture the value that will determine if
        // user wants to keep his session
        userDocument.getDocument() { (document, err) in
            // Check for errors
            if let err = err {
                // Show error on console
                print("Error fetching document: \(err.localizedDescription)")
                
                // Errors could be caused by Security Rules of database
                // Or because document doesn't exist.
                
                // For the mean time, push to Log In View
                if !self.isKind(of: LogInViewController.self) { // Prevents repeat of push
                    self.numberOfPushes += 1
                    if self.numberOfPushes == 1 {
                        self.performSegue(withIdentifier: "toLogInView", sender: nil)
                    }
                }
            } else {
                // Just to be sure, check if document is empty
                if let document = document {
                    // Show on console id of the user document
                    print("Document ID: \(document.documentID)")
                    
                    // Loop through all the datas in document
                    for data in document.data()! {
                        // Filter data through its keys
                        if data.key == "rememberMe" {
                            // For the mean time, to avoid errors, completion will return
                            // false if value captured is nil
                            completion(data.value as? Bool ?? false)
                            
                            // Show value on console for debugging
                            print("isUserSessionOn: \(data.value)")
                        }
                    }
                } else {
                    // Show error on console
                    print("Document is empty. It is possible that it doesn't exist.")
                    
                    // If user document doesn't exists, ask user to
                    // create another account and apologize
                    
                    // But first, sign out the user and delete
                    // existing FirebaseUser object. This is to delete
                    // the user's session and avoid errors
                    self.signOutUser()
                    self.deleteCurrentUser()
                    
                    // Then push view to Create Account View
                    // for user to re-create his account. Note that
                    // he can still use his the previous email
                    self.performSegue(withIdentifier: "launchToCreateAccount", sender: nil)
                }
            }
        }
    }
    
    // Sign out user and end his session
    func signOutUser() {
        do { try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // Deletes current logged in user
    func deleteCurrentUser() {
        Auth.auth().currentUser?.delete() { (err) in
            // Check for errors
            if let err = err {
                // Show error on console
                print("Error deleting user: \(err.localizedDescription)")
            } else {
                // Show message on console
                print("User is successfully deleted.")
            }
        }
    }
    
    // Prepare segues. Through segues you can pass
    // a data from one controller to another
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Since there are multiple segues, filter user
        // identifier and pass values needed on each
        if segue.identifier == "toLogInView" {
            // For Log In View
            
        } else if segue.identifier == "launchToCreateAccount" {
            // For Create Account View
            
            
        } else if segue.identifier == "launchToFeedView" {
            // For Feed View
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
