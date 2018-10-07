//
//  ReactCell.swift
//  dumpsite
//
//  Created by Elisha Saylon on 06/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class ReactCell: UITableViewCell {

    // Tag Views
    @IBOutlet var reactsBorder: UIImageView!
    @IBOutlet var moodName: UILabel!
    
    @IBOutlet var react1: UIButton!
    @IBOutlet var react2: UIButton!
    @IBOutlet var react3: UIButton!
    @IBOutlet var react4: UIButton!
    @IBOutlet var react5: UIButton!
    
    // Data
    var reactStates = ["Happy": false, "Tease": false, "Crying": false, "Bored": false, "Angry": false]
    var reactBtns = [String: UIButton]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round corners of Views
        reactsBorder.layer.cornerRadius = 30
        reactsBorder.clipsToBounds = true
        moodName.layer.cornerRadius = 12
        moodName.clipsToBounds = true
        
        // Hide label for Mood
        moodName.alpha = 0
        
        // Add buttons to array
        addButtons()
    }

    // Reference to FeelsCell
    func commonInit() {
        
    }
    
    func addButtons() {
        reactBtns.updateValue(react1, forKey: "Happy")
        reactBtns.updateValue(react2, forKey: "Tease")
        reactBtns.updateValue(react3, forKey: "Crying")
        reactBtns.updateValue(react4, forKey: "Bored")
        reactBtns.updateValue(react5, forKey: "Angry")
    }
    
    // React button Actions
    @IBAction func react1(_ sender: UIButton) {
        // Set mood name
        moodName.text = sender.currentTitle!
        
        // Show mood name and emphaszied selected react
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.moodName.alpha = 1 // Show mood name
            // For animation to happen once
            if self.reactStates[sender.currentTitle!] == false {
                sender.frame = CGRect(x: sender.frame.minX - 3, y: sender.frame.minY - 3, width: sender.frame.width + 6, height: sender.frame.height + 6)
                // Set state of react
                self.reactStates[sender.currentTitle!] = true
                
                // Check for other react states
                for state in self.reactStates {
                    if state.key != sender.currentTitle! {
                        if state.value == true {
                            // Revert back to default button size
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.reactBtns[state.key]?.frame = CGRect(x: (self.reactBtns[state.key]?.frame.minX)! + 3, y: (self.reactBtns[state.key]?.frame.minY)! + 3, width: (self.reactBtns[state.key]?.frame.width)! - 6, height: (self.reactBtns[state.key]?.frame.width)! - 6)
                            })
                            self.reactStates.updateValue(false, forKey: state.key)
                        }
                    }
                }
            }
        })
        
        // Hide mood name
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.moodName.alpha = 0
        })
    }
    
    @IBAction func react2(_ sender: UIButton) {
        // Set mood name
        moodName.text = sender.currentTitle!
        
        // Show mood name and emphaszied selected react
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.moodName.alpha = 1 // Show mood name
            // For animation to happen once
            if self.reactStates[sender.currentTitle!] == false {
                sender.frame = CGRect(x: sender.frame.minX - 3, y: sender.frame.minY - 3, width: sender.frame.width + 6, height: sender.frame.height + 6)
                // Set state of react
                self.reactStates[sender.currentTitle!] = true
                
                // Check for other react states
                for state in self.reactStates {
                    if state.key != sender.currentTitle! {
                        if state.value == true {
                            // Revert back to default button size
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.reactBtns[state.key]?.frame = CGRect(x: (self.reactBtns[state.key]?.frame.minX)! + 3, y: (self.reactBtns[state.key]?.frame.minY)! + 3, width: (self.reactBtns[state.key]?.frame.width)! - 6, height: (self.reactBtns[state.key]?.frame.width)! - 6)
                            })
                            self.reactStates.updateValue(false, forKey: state.key)
                        }
                    }
                }
            }
        })
        
        // Hide mood name
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.moodName.alpha = 0
        })
    }
    
    @IBAction func react3(_ sender: UIButton) {
        // Set mood name
        moodName.text = sender.currentTitle!
        
        // Show mood name and emphaszied selected react
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.moodName.alpha = 1 // Show mood name
            // For animation to happen once
            if self.reactStates[sender.currentTitle!] == false {
                sender.frame = CGRect(x: sender.frame.minX - 3, y: sender.frame.minY - 3, width: sender.frame.width + 6, height: sender.frame.height + 6)
                // Set state of react
                self.reactStates[sender.currentTitle!] = true
                
                // Check for other react states
                for state in self.reactStates {
                    if state.key != sender.currentTitle! {
                        if state.value == true {
                            // Revert back to default button size
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.reactBtns[state.key]?.frame = CGRect(x: (self.reactBtns[state.key]?.frame.minX)! + 3, y: (self.reactBtns[state.key]?.frame.minY)! + 3, width: (self.reactBtns[state.key]?.frame.width)! - 6, height: (self.reactBtns[state.key]?.frame.width)! - 6)
                            })
                            self.reactStates.updateValue(false, forKey: state.key)
                        }
                    }
                }
            }
        })
        
        // Hide mood name
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.moodName.alpha = 0
        })
    }
    
    @IBAction func react4(_ sender: UIButton) {
        // Set mood name
        moodName.text = sender.currentTitle!
        
        // Show mood name and emphaszied selected react
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.moodName.alpha = 1 // Show mood name
            // For animation to happen once
            if self.reactStates[sender.currentTitle!] == false {
                sender.frame = CGRect(x: sender.frame.minX - 3, y: sender.frame.minY - 3, width: sender.frame.width + 6, height: sender.frame.height + 6)
                // Set state of react
                self.reactStates[sender.currentTitle!] = true
                
                // Check for other react states
                for state in self.reactStates {
                    if state.key != sender.currentTitle! {
                        if state.value == true {
                            // Revert back to default button size
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.reactBtns[state.key]?.frame = CGRect(x: (self.reactBtns[state.key]?.frame.minX)! + 3, y: (self.reactBtns[state.key]?.frame.minY)! + 3, width: (self.reactBtns[state.key]?.frame.width)! - 6, height: (self.reactBtns[state.key]?.frame.width)! - 6)
                            })
                            self.reactStates.updateValue(false, forKey: state.key)
                        }
                    }
                }
            }
        })
        
        // Hide mood name
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.moodName.alpha = 0
        })
    }
    
    @IBAction func react5(_ sender: UIButton) {
        // Set mood name
        moodName.text = sender.currentTitle!
        
        // Show mood name and emphaszied selected react
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.moodName.alpha = 1 // Show mood name
            // For animation to happen once
            if self.reactStates[sender.currentTitle!] == false {
                sender.frame = CGRect(x: sender.frame.minX - 3, y: sender.frame.minY - 3, width: sender.frame.width + 6, height: sender.frame.height + 6)
                // Set state of react
                self.reactStates[sender.currentTitle!] = true
                
                // Check for other react states
                for state in self.reactStates {
                    if state.key != sender.currentTitle! {
                        if state.value == true {
                            // Revert back to default button size
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.reactBtns[state.key]?.frame = CGRect(x: (self.reactBtns[state.key]?.frame.minX)! + 3, y: (self.reactBtns[state.key]?.frame.minY)! + 3, width: (self.reactBtns[state.key]?.frame.width)! - 6, height: (self.reactBtns[state.key]?.frame.width)! - 6)
                            })
                            self.reactStates.updateValue(false, forKey: state.key)
                        }
                    }
                }
            }
        })
        
        // Hide mood name
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.moodName.alpha = 0
        })
    }
}
