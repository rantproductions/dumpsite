//
//  AddTrashcanCell.swift
//  dumpsite
//
//  Created by Elisha Saylon on 12/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class AddTrashcanCell: UICollectionViewCell {

    // Tag Views
    @IBOutlet var addTrashcanBorder: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Make corners round
        roundCorners()
        dashedBorder()
    }
    
    func roundCorners() {
        addTrashcanBorder.layer.cornerRadius = 12
        addTrashcanBorder.clipsToBounds = true
    }
    
    func dashedBorder() {
        let dashedBorder = CAShapeLayer()
        dashedBorder.strokeColor = UIColor.white.cgColor
        dashedBorder.fillColor = nil
        dashedBorder.lineDashPattern = [7, 7]
        dashedBorder.lineWidth = 4
        dashedBorder.frame = addTrashcanBorder.bounds
        dashedBorder.path = UIBezierPath(rect: addTrashcanBorder.bounds).cgPath
        addTrashcanBorder.layer.addSublayer(dashedBorder)
    }
    
    func commonInit() {

    }

}
