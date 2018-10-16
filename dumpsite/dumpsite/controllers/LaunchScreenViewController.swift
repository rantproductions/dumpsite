//
//  LaunchScreenViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 10/17/18.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class LaunchScreenViewController: UIViewController {

    // Firestore References
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeNavigationBarTransparent()
        hideBackButton()
        
        getFirestoreDatabase()
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
}
