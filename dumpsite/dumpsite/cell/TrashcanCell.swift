//
//  TrashcanCell.swift
//  dumpsite
//
//  Created by Elisha Saylon on 12/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class TrashcanCell: UICollectionViewCell {

    // Tag Views
    @IBOutlet var trashcanBorder: UIImageView!
    @IBOutlet weak var btnDelete: UIImageView!
    @IBOutlet var trashcanLabel: UILabel!
    
    // Data
    var trashcanName: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundCorners()
    }
    
    func roundCorners() {
        trashcanBorder.layer.cornerRadius = 12
        trashcanBorder.clipsToBounds = true
    }
    
    func setUpTrashcanName() {
        trashcanLabel.text = trashcanName
    }
    
    func commonInit(_ trashcanName: String) {
        self.trashcanName = trashcanName
    }
    
    func shakeCell() {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        let startAngle = (-2) * 3.14159/180
        let stopAngle = -startAngle
        
        shakeAnimation.fromValue = NSNumber(value: startAngle)
        shakeAnimation.toValue = NSNumber(value: stopAngle)
        shakeAnimation.autoreverses = true
        shakeAnimation.duration = 0.2
        shakeAnimation.repeatCount = 10000
        shakeAnimation.timeOffset = 290 * drand48()
        
        let animationLayer = self.layer
        animationLayer.add(shakeAnimation, forKey: "Shake")
    }

    func stopShake() {
        let animationLayer = self.layer
        animationLayer.removeAnimation(forKey: "Shake")
    }
}
