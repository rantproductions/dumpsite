//
//  TrashcanContentViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 14/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class TrashcanContentViewController: UIViewController {

    // Tag Vies
    @IBOutlet var trashcanName: UILabel!
    
    var trashcanNo = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set trashcan name
        trashcanName.text = "TRASHCAN \(trashcanNo)"
    }
    
    func commonInit(_ trashcanNo: Int) {
        self.trashcanNo = trashcanNo
    }

}
