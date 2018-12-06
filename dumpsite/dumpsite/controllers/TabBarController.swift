//
//  TabBarController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 12/4/18.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        makeNavigationBarTransparent()
        hideBackButton()
        changeTabBarTints()
    }

    // Make navigation bar transparent
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
    
    func changeTabBarTints() {
        if #available(iOS 10.0, *) {
            self.tabBar.unselectedItemTintColor = UIColor.white
        }
    }
}
