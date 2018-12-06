//
//  ReactCell.swift
//  dumpsite
//
//  Created by Elisha Saylon on 06/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class ReactCell: UITableViewCell {

    // Tag Views
    @IBOutlet var reactsBorder: UIImageView!
    @IBOutlet var reactName: UILabel!
    
    @IBOutlet var react1: UIButton!
    @IBOutlet var react2: UIButton!
    @IBOutlet var react3: UIButton!
    @IBOutlet var react4: UIButton!
    @IBOutlet var react5: UIButton!
    
    // Data
    var userId: String!
    
    var reactStates = ["Happy": false, "Tease": false, "Crying": false, "Bored": false, "Angry": false]
    var feelsId: String!
    var reactCount = [String: Int]()
    var userIdList = [String: [String]]()
    var timestamp: Timestamp!
    
    var reactBtns = [String: UIButton]()
    
    // Firestore References
    var firestoredb: Firestore!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        getFirestoreDatabase()
        getCurrentUserId()
        
        addButtons()
        makeCornersRound()
        hideReactLabel()
    }
    
    // Gets firstore reference and fixes date bug
    func getFirestoreDatabase() {
        // Get reference to Dumpsite's Firestore Database
        firestoredb = Firestore.firestore()
        
        // Avoid breaking the app cause by the change of behavior
        // of system Date objects
        let settings = firestoredb.settings
        settings.areTimestampsInSnapshotsEnabled = true
        firestoredb.settings = settings
    }
    
    func getCurrentUserId() {
        userId = Auth.auth().currentUser?.uid
    }
    
    func makeCornersRound() {
        reactsBorder.layer.cornerRadius = 26
        reactsBorder.clipsToBounds = true
        reactName.layer.cornerRadius = 12
        reactName.clipsToBounds = true
    }
    
    func hideReactLabel() {
        reactName.alpha = 0
    }
    
    func addButtons() {
        reactBtns.updateValue(react1, forKey: "Happy")
        reactBtns.updateValue(react2, forKey: "Tease")
        reactBtns.updateValue(react3, forKey: "Crying")
        reactBtns.updateValue(react4, forKey: "Bored")
        reactBtns.updateValue(react5, forKey: "Angry")
    }

    // Reference to FeelsCell
    func commonInit(_ feelsId: String, _ reactCount: [String: Int], _ userIdList: [String: [String]], _ timestamp: Timestamp) {
        self.feelsId = feelsId
        self.reactCount = reactCount
        self.userIdList = userIdList
        self.timestamp = timestamp

        clearReactData()
        checkUserReact()
    }
    
    func clearReactData() {
        reactCount.removeValue(forKey: "")
        userIdList.removeValue(forKey: "")
        
        print("React Id: \(feelsId!)")
        print("React Count: \(reactCount)")
        print("User Ids: \(userIdList)")
    }
    
    func checkUserReact() {
        var currentReact = String()
        
        for react in userIdList {
            currentReact = react.key
            
            if react.value.contains(userId) {
                reactName.text = currentReact
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.reactName.alpha = 1
                    
                    if self.reactStates[currentReact] == false {
                        self.reactBtns[currentReact]!.frame = CGRect(x: self.reactBtns[currentReact]!.frame.minX - 3, y: self.reactBtns[currentReact]!.frame.minY - 3, width: self.reactBtns[currentReact]!.frame.width + 6, height: self.reactBtns[currentReact]!.frame.height + 6)
                        
                        self.reactStates[currentReact] = true
                        
                        for state in self.reactStates {
                            if state.key != currentReact {
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
                    self.reactName.alpha = 0
                })
                
                return
            } else {
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.reactName.alpha = 0
                    
                    for state in self.reactStates {
                        if state.value == true {
                            // Revert back to default button size
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.reactBtns[state.key]?.frame = CGRect(x: (self.reactBtns[state.key]?.frame.minX)! + 3, y: (self.reactBtns[state.key]?.frame.minY)! + 3, width: (self.reactBtns[state.key]?.frame.width)! - 6, height: (self.reactBtns[state.key]?.frame.width)! - 6)
                            })
                            self.reactStates.updateValue(false, forKey: state.key)
                        }
                    }
                })
            }
        }
    }
    
    func updateReact() {
        var reactArray = [String : Any]()
        
        var index = 0
        for feelsReact in reactCount {
            let react = React(reactName: feelsReact.key, reactCount: feelsReact.value, userIdList: userIdList[feelsReact.key]!)
            reactArray.updateValue(react.dictionary, forKey: "react\(index)")
            index += 1
        }
        
        let reactions = Reactions(feelsId: feelsId, reactions: reactArray, timestamp: timestamp)
        firestoredb.collection("reactions").document(feelsId).setData(reactions.dictionary, merge: true) { err in
            if let err = err {
                print("Error updating reactions to feels! \(err.localizedDescription)")
            } else {
                print("Updated reactions for \(self.feelsId!) feels!")
            }
        }
    }
    
    // React button Actions
    @IBAction func react1(_ sender: UIButton) {
        // Set mood name
        reactName.text = sender.currentTitle!
        
        // Show mood name and emphaszied selected react
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.reactName.alpha = 1 // Show mood name
            // For animation to happen once
            if self.reactStates[sender.currentTitle!] == false {
                sender.frame = CGRect(x: sender.frame.minX - 3, y: sender.frame.minY - 3, width: sender.frame.width + 6, height: sender.frame.height + 6)
                // Set state of react
                self.reactStates[sender.currentTitle!] = true
                
                // Increment react count
                let count = self.reactCount[sender.currentTitle!]! + 1
                self.reactCount.updateValue(count, forKey: sender.currentTitle!)
                
                var idList = self.userIdList[sender.currentTitle!]
                idList?.append(self.userId)
                self.userIdList.updateValue(idList!, forKey: sender.currentTitle!)
                
                print("React Count: \(self.reactCount)")
                print("User Ids: \(self.userIdList)")
                
                // Check for other react states
                for state in self.reactStates {
                    if state.key != sender.currentTitle! {
                        if state.value == true {
                            // Revert back to default button size
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.reactBtns[state.key]?.frame = CGRect(x: (self.reactBtns[state.key]?.frame.minX)! + 3, y: (self.reactBtns[state.key]?.frame.minY)! + 3, width: (self.reactBtns[state.key]?.frame.width)! - 6, height: (self.reactBtns[state.key]?.frame.width)! - 6)
                            })
                            self.reactStates.updateValue(false, forKey: state.key)
                            
                            let count = self.reactCount[state.key]! - 1
                            self.reactCount.updateValue(count, forKey: state.key)
                            
                            var idList = self.userIdList[state.key]
                            idList?.removeAll{$0 == self.userId}
                            self.userIdList.updateValue(idList!, forKey: state.key)
                            
                            print("React Count: \(self.reactCount)")
                            print("User Ids: \(self.userIdList)")
                        }
                    }
                }
                
                self.updateReact()
            }
        })
        
        // Hide mood name
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.reactName.alpha = 0
        })
    }
    
    @IBAction func react2(_ sender: UIButton) {
        // Set mood name
        reactName.text = sender.currentTitle!
        
        // Show mood name and emphaszied selected react
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.reactName.alpha = 1 // Show mood name
            // For animation to happen once
            if self.reactStates[sender.currentTitle!] == false {
                sender.frame = CGRect(x: sender.frame.minX - 3, y: sender.frame.minY - 3, width: sender.frame.width + 6, height: sender.frame.height + 6)
                // Set state of react
                self.reactStates[sender.currentTitle!] = true
                
                let count = self.reactCount[sender.currentTitle!]! + 1
                self.reactCount.updateValue(count, forKey: sender.currentTitle!)
                
                var idList = self.userIdList[sender.currentTitle!]
                idList?.append(self.userId)
                self.userIdList.updateValue(idList!, forKey: sender.currentTitle!)
                
                print("React Count: \(self.reactCount)")
                print("User Ids: \(self.userIdList)")
                
                // Check for other react states
                for state in self.reactStates {
                    if state.key != sender.currentTitle! {
                        if state.value == true {
                            // Revert back to default button size
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.reactBtns[state.key]?.frame = CGRect(x: (self.reactBtns[state.key]?.frame.minX)! + 3, y: (self.reactBtns[state.key]?.frame.minY)! + 3, width: (self.reactBtns[state.key]?.frame.width)! - 6, height: (self.reactBtns[state.key]?.frame.width)! - 6)
                            })
                            self.reactStates.updateValue(false, forKey: state.key)
                            
                            let count = self.reactCount[state.key]! - 1
                            self.reactCount.updateValue(count, forKey: state.key)
                            
                            var idList = self.userIdList[state.key]
                            idList?.removeAll{$0 == self.userId}
                            self.userIdList.updateValue(idList!, forKey: state.key)
                            
                            print("React Count: \(self.reactCount)")
                            print("User Ids: \(self.userIdList)")
                        }
                    }
                }
                
                self.updateReact()
            }
        })
        
        // Hide mood name
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.reactName.alpha = 0
        })
    }
    
    @IBAction func react3(_ sender: UIButton) {
        // Set mood name
        reactName.text = sender.currentTitle!
        
        // Show mood name and emphaszied selected react
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.reactName.alpha = 1 // Show mood name
            // For animation to happen once
            if self.reactStates[sender.currentTitle!] == false {
                sender.frame = CGRect(x: sender.frame.minX - 3, y: sender.frame.minY - 3, width: sender.frame.width + 6, height: sender.frame.height + 6)
                // Set state of react
                self.reactStates[sender.currentTitle!] = true
                
                let count = self.reactCount[sender.currentTitle!]! + 1
                self.reactCount.updateValue(count, forKey: sender.currentTitle!)
                
                var idList = self.userIdList[sender.currentTitle!]
                idList?.append(self.userId)
                self.userIdList.updateValue(idList!, forKey: sender.currentTitle!)
                
                print("React Count: \(self.reactCount)")
                print("User Ids: \(self.userIdList)")
                
                // Check for other react states
                for state in self.reactStates {
                    if state.key != sender.currentTitle! {
                        if state.value == true {
                            // Revert back to default button size
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.reactBtns[state.key]?.frame = CGRect(x: (self.reactBtns[state.key]?.frame.minX)! + 3, y: (self.reactBtns[state.key]?.frame.minY)! + 3, width: (self.reactBtns[state.key]?.frame.width)! - 6, height: (self.reactBtns[state.key]?.frame.width)! - 6)
                            })
                            self.reactStates.updateValue(false, forKey: state.key)
                            
                            let count = self.reactCount[state.key]! - 1
                            self.reactCount.updateValue(count, forKey: state.key)
                            
                            var idList = self.userIdList[state.key]
                            idList?.removeAll{$0 == self.userId}
                            self.userIdList.updateValue(idList!, forKey: state.key)
                            
                            print("React Count: \(self.reactCount)")
                            print("User Ids: \(self.userIdList)")
                        }
                    }
                }
                
                self.updateReact()
            }
        })
        
        // Hide mood name
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.reactName.alpha = 0
        })
    }
    
    @IBAction func react4(_ sender: UIButton) {
        // Set mood name
        reactName.text = sender.currentTitle!
        
        // Show mood name and emphaszied selected react
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.reactName.alpha = 1 // Show mood name
            // For animation to happen once
            if self.reactStates[sender.currentTitle!] == false {
                sender.frame = CGRect(x: sender.frame.minX - 3, y: sender.frame.minY - 3, width: sender.frame.width + 6, height: sender.frame.height + 6)
                // Set state of react
                self.reactStates[sender.currentTitle!] = true
                
                let count = self.reactCount[sender.currentTitle!]! + 1
                self.reactCount.updateValue(count, forKey: sender.currentTitle!)
                
                var idList = self.userIdList[sender.currentTitle!]
                idList?.append(self.userId)
                self.userIdList.updateValue(idList!, forKey: sender.currentTitle!)
                
                print("React Count: \(self.reactCount)")
                print("User Ids: \(self.userIdList)")
                
                // Check for other react states
                for state in self.reactStates {
                    if state.key != sender.currentTitle! {
                        if state.value == true {
                            // Revert back to default button size
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.reactBtns[state.key]?.frame = CGRect(x: (self.reactBtns[state.key]?.frame.minX)! + 3, y: (self.reactBtns[state.key]?.frame.minY)! + 3, width: (self.reactBtns[state.key]?.frame.width)! - 6, height: (self.reactBtns[state.key]?.frame.width)! - 6)
                            })
                            self.reactStates.updateValue(false, forKey: state.key)
                            
                            let count = self.reactCount[state.key]! - 1
                            self.reactCount.updateValue(count, forKey: state.key)
                            
                            var idList = self.userIdList[state.key]
                            idList?.removeAll{$0 == self.userId}
                            self.userIdList.updateValue(idList!, forKey: state.key)
                            
                            print("React Count: \(self.reactCount)")
                            print("User Ids: \(self.userIdList)")
                        }
                    }
                }
                
                self.updateReact()
            }
        })
        
        // Hide mood name
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.reactName.alpha = 0
        })
    }
    
    @IBAction func react5(_ sender: UIButton) {
        // Set mood name
        reactName.text = sender.currentTitle!
        
        // Show mood name and emphaszied selected react
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.reactName.alpha = 1 // Show mood name
            // For animation to happen once
            if self.reactStates[sender.currentTitle!] == false {
                sender.frame = CGRect(x: sender.frame.minX - 3, y: sender.frame.minY - 3, width: sender.frame.width + 6, height: sender.frame.height + 6)
                // Set state of react
                self.reactStates[sender.currentTitle!] = true
                
                let count = self.reactCount[sender.currentTitle!]! + 1
                self.reactCount.updateValue(count, forKey: sender.currentTitle!)
                
                var idList = self.userIdList[sender.currentTitle!]
                idList?.append(self.userId)
                self.userIdList.updateValue(idList!, forKey: sender.currentTitle!)
                
                print("React Count: \(self.reactCount)")
                print("User Ids: \(self.userIdList)")
                
                // Check for other react states
                for state in self.reactStates {
                    if state.key != sender.currentTitle! {
                        if state.value == true {
                            // Revert back to default button size
                            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                self.reactBtns[state.key]?.frame = CGRect(x: (self.reactBtns[state.key]?.frame.minX)! + 3, y: (self.reactBtns[state.key]?.frame.minY)! + 3, width: (self.reactBtns[state.key]?.frame.width)! - 6, height: (self.reactBtns[state.key]?.frame.width)! - 6)
                            })
                            self.reactStates.updateValue(false, forKey: state.key)
                            
                            let count = self.reactCount[state.key]! - 1
                            self.reactCount.updateValue(count, forKey: state.key)
                            
                            var idList = self.userIdList[state.key]
                            idList?.removeAll{$0 == self.userId}
                            self.userIdList.updateValue(idList!, forKey: state.key)
                            
                            print("React Count: \(self.reactCount)")
                            print("User Ids: \(self.userIdList)")
                        }
                    }
                }
                
                self.updateReact()
            }
        })
        
        // Hide mood name
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.reactName.alpha = 0
        })
    }
}
