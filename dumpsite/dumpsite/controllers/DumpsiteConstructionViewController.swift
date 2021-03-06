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

    // Tag Views
    @IBOutlet var btnOpenDumpsite: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeNavigationBarTransparent()
        hideBackButton()
        makeRoundCorners()
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
    
    // Make corners round
    func makeRoundCorners() {
        btnOpenDumpsite.layer.cornerRadius = 12
        btnOpenDumpsite.clipsToBounds = true
    }
}
