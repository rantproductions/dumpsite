//
//  FeelsTextView.swift
//  dumpsite
//
//  Created by Elisha Saylon on 06/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class FeelsTextView: UITextView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Add padding to TextView
        textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
