//
//  FeelsCell.swift
//  dumpsite
//
//  Created by Elisha Saylon on 05/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class FeelsCell: UITableViewCell {

    // Tag Views
    @IBOutlet var moodFrame: UIImageView!
    @IBOutlet var moodImage: UIImageView!
    @IBOutlet var feelsContent: FeelsTextView!
    
    // Data
    var userId = String()
    var trashcan = String()
    var timestamp = Timestamp()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round corners of View
        moodFrame.layer.cornerRadius = 15
        moodFrame.clipsToBounds = true
        feelsContent.layer.cornerRadius = 8
        feelsContent.clipsToBounds = true
    }
    
    // Call this in Feed View Controller to assign values
    func commonInit(_ moodName: String, _ content: String, _ userId: String, _ trashcan: String, _ timestamp: Timestamp) {

        moodImage.image = UIImage(named: moodName)
        feelsContent.text = content
        
        self.userId = userId
        self.trashcan = trashcan
        self.timestamp = timestamp
    }
    
}
