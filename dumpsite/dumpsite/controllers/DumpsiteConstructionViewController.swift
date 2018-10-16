//
//  DumpsiteConstructionViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 10/16/18.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class DumpsiteConstructionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        makeNavigationBarTransparent()
        hideBackButton()
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
    
    // Redirects user to Log In Page if email is verified
    func isEmailVerified() {
        
    }
}
