//
//  CustomSwitch.swift
//  dumpsite
//
//  Created by Elisha Saylon on 10/16/18.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class CustomSwitch: UIControl {

    // Public variables
    public var onTintColor = UIColor(red: 144/255, green: 202/255, blue: 119/255, alpha: 1)
    public var offTintColor = UIColor.lightGray
    public var cornerRadius: CGFloat = 0.5
    public var thumbTintColor = UIColor.white
    public var thumbCornerRadius: CGFloat = 0.5
    public var thumbSize = CGSize.zero
    public var padding: CGFloat = 1
    
    public var isOn = true
    public var animationDuration: Double = 0.5
    
    // Fileprivates
    fileprivate var thumbView = UIView(frame: CGRect.zero)
    fileprivate var onPoint = CGPoint.zero
    fileprivate var offPoint = CGPoint.zero
    fileprivate var isAnimating = false

    // Remove everything from the view heirarchy in case
    // we need to reset UI
    private func clear() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    // Initial configuration of UI
    func setupUI() {
        self.clear()
        self.clipsToBounds = false
        self.thumbView.backgroundColor = self.thumbTintColor
        self.thumbView.isUserInteractionEnabled = false
        self.addSubview(self.thumbView)
    }
    
    // Creates the layout of custom conyrol
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // Make sure animation is not active
        if !self.isAnimating {
            self.layer.cornerRadius = self.bounds.size.height * self.cornerRadius
            self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
            
            // Thumb management
            let thumbSize = self.thumbSize != CGSize.zero ? self.thumbSize : CGSize(width:
                self.bounds.size.height - 2, height: self.bounds.height - 2)
            let yPostition = (self.bounds.size.height - thumbSize.height) / 2
            
            self.onPoint = CGPoint(x: self.bounds.size.width - thumbSize.width - self.padding, y: yPostition)
            self.offPoint = CGPoint(x: self.padding, y: yPostition)
            
            self.thumbView.frame = CGRect(origin: self.isOn ? self.onPoint : self.offPoint, size: thumbSize)
            self.thumbView.layer.cornerRadius = thumbSize.height * self.thumbCornerRadius
        }
        
    }
}
