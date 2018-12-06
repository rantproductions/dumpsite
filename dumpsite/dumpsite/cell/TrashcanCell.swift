//
//  TrashcanCell.swift
//  dumpsite
//
//  Created by Elisha Saylon on 12/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class TrashcanCell: UICollectionViewCell {

    // Tag Views
    @IBOutlet var trashcanBorder: UIImageView!
    @IBOutlet weak var btnDelete: UIImageView!
    @IBOutlet var trashcanName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Make corners round
        roundCorners()
    }
    
    func roundCorners() {
        trashcanBorder.layer.cornerRadius = 12
        trashcanBorder.clipsToBounds = true
    }
    
    func commonInit() {
        
    }

}
