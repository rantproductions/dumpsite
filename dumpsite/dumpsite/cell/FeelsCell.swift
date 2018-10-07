//
//  FeelsCell.swift
//  dumpsite
//
//  Created by Elisha Saylon on 05/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class FeelsCell: UITableViewCell {

    // Tag Views
    @IBOutlet var moodFrame: UIImageView!
    @IBOutlet var moodImage: UIImageView!
    @IBOutlet var feelsContent: FeelsTextView!
    @IBOutlet var btnShowReacts: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round corners of View
        moodFrame.layer.cornerRadius = 15
        moodFrame.clipsToBounds = true
        btnShowReacts.layer.cornerRadius = 8
        btnShowReacts.clipsToBounds = true
        feelsContent.layer.cornerRadius = 8
        feelsContent.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // Call this in Feed View Controller to assign values
    func commonInit(_ moodName: String) {
        // Set the image of the Mood
        moodImage.image = UIImage(named: moodName)
    }
    
}
