//
//  ViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 04/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    // Tag Views
    @IBOutlet var btnLogIn: UIButton!
    
    // Data
    var db: Firestore!
    var users: DocumentReference!
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeNavigationBarTransparent()
        hideBackButton()
        // customLogInButton()
        
        // Get firestore reference
        getFirestoreDatabase()
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
    
    func customLogInButton() {
        btnLogIn.layer.cornerRadius = 30
        btnLogIn.clipsToBounds = true
        
        let customBorder = CAShapeLayer()
        customBorder.fillColor = nil
        customBorder.lineWidth = 5
        customBorder.strokeColor = UIColor.white.cgColor
        customBorder.frame = btnLogIn.bounds
        customBorder.path = UIBezierPath(rect: btnLogIn.bounds).cgPath
        btnLogIn.layer.addSublayer(customBorder)
    }
    
    func getFirestoreDatabase() {
        db = Firestore.firestore()
    }
    
    
}

