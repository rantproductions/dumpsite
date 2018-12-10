//
//  TrashcanContentViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 14/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class TrashcanContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Tag Views
    @IBOutlet var trashcanNameLabel: UILabel!
    @IBOutlet var feedView: UITableView!
    
    // Data
    var trashcanName: String!
    var userId: String!
    
    var listenToFeels = true
    var feelsArray = [Feels]()
    var reactNibOpen = [Bool]()
    var removeIndex = [Int]()
    var index = 0
    
    var reactionsArray = [Reactions]()
    var currentReact: Int!
    
    // Firebase Reference
    var firestoredb: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFirestoreDatabase()
        getCurrentUser()
        getAllFeels()
        
        setTrashcanName()
        setFeedView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listenToFeels = false
        
        feelsArray.removeAll()
        reactNibOpen.removeAll()
        reactionsArray.removeAll()
        feedView.reloadData()
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
    
    func getCurrentUser() {
        userId = Auth.auth().currentUser?.uid
    }
    
    func getAllFeels() {
        let feelsListener = firestoredb.collection("feels").order(by: "timestamp", descending: true)
            .addSnapshotListener() { (querySnapshot, err) in
                guard let querySnapshot = querySnapshot else { return }
                querySnapshot.documentChanges.forEach { diff in
                    if diff.type == .added {
                        let feels = Feels(dictionary: diff.document.data())!
                        if feels.userId == self.userId, feels.trashcan == self.trashcanName {
                            self.feelsArray.append(feels)
                            self.reactNibOpen.append(false)
                        }
                        
                        self.removeIndex.append(self.index)
                        self.index += 1
                }
                
                DispatchQueue.main.async {
                    self.feedView.reloadData()
                }
            }
        }
        
        index = 0
        let reactsListener = firestoredb.collection("reactions").order(by: "timestamp", descending: true)
            .addSnapshotListener() { (querySnapshot, err) in
                guard let querySnapshot = querySnapshot else { return }
                querySnapshot.documentChanges.forEach { diff in
                    if diff.type == .modified {
                        if !self.removeIndex.contains(self.index) {
                            self.reactionsArray[self.currentReact] = Reactions(dictionary: diff.document.data())!
                        }
                    } else if diff.type == .added {
                        if !self.removeIndex.contains(self.index) {
                            self.reactionsArray.append(Reactions(dictionary: diff.document.data())!)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.feedView.reloadData()
                }
        }
                
        if !listenToFeels {
            feelsListener.remove()
            reactsListener.remove()
        }
    }
    
    func commonInit(_ trashcanName: String) {
        self.trashcanName = trashcanName
    }

    func setTrashcanName()
    {
        trashcanNameLabel.text = trashcanName.lowercased()
    }
    
    func setFeedView() {
        feedView.delegate = self
        feedView.dataSource = self
        
        let feelsCell = UINib(nibName: "FeelsCell", bundle: nil)
        let reactCell = UINib(nibName: "ReactCell", bundle: nil)
        feedView.register(feelsCell, forCellReuseIdentifier: "feelsCell")
        feedView.register(reactCell, forCellReuseIdentifier: "reactCell")
        
        let feedViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        feedView.contentInset = feedViewInsets
        
        // Fix table cell expand glitch
        feedView.rowHeight = UITableView.automaticDimension
        feedView.estimatedRowHeight = 160
        
        feedView.estimatedSectionHeaderHeight = 0
        feedView.estimatedSectionFooterHeight = 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return feelsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reactNibOpen[section] == false { // else return the feelsCell only
            return 1
        }
        else { // if react is open, return the feelsCell and reactCell
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // feelsCell always index 0
        if indexPath.row == 0 {
            let cell = feedView.dequeueReusableCell(withIdentifier: "feelsCell") as! FeelsCell
            let feels = feelsArray[indexPath.section]
            cell.commonInit(feels.moodImage, feels.content, feels.userId, feels.trashcan, feels.timestamp)
            
            // Make background of custom cell transparent
            cell.backgroundColor = .clear
            cell.backgroundView = UIView()
            cell.selectedBackgroundView = UIView()
            return cell
        } else {
            // the rest of the cells under the feelsCell
            let cell = feedView.dequeueReusableCell(withIdentifier: "reactCell") as! ReactCell
            currentReact = indexPath.section
            
            let feelsReaction = reactionsArray[indexPath.section]
            var reactCount = [String: Int]()
            var userIdList = [String: [String]]()
            
            for react in feelsReaction.reactions {
                let value = react.value as! [String: Any]
                
                var reactName = String()
                var count = Int()
                var idList = [String]()
                
                for reactData in value {
                    if(reactData.key == "reactCount") {
                        count = reactData.value as! Int
                    }
                    
                    if(reactData.key == "reactName") {
                        reactName = reactData.value as! String
                    }
                    
                    if(reactData.key == "userIdList") {
                        idList = reactData.value as! [String]
                    }
                    
                    reactCount.updateValue(count, forKey: reactName)
                    userIdList.updateValue(idList, forKey: reactName)
                }
            }
            
            cell.commonInit(feelsReaction.feelsId, reactCount, userIdList, feelsReaction.timestamp)
            
            // Make background of custom cell transparent
            cell.backgroundColor = .clear
            cell.backgroundView = UIView()
            cell.selectedBackgroundView = UIView()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reactNibOpen[indexPath.section] == true {
            reactNibOpen[indexPath.section] = false
            let section = IndexSet.init(integer: indexPath.section)
            feedView.reloadSections(section, with: .fade)
        } else {
            // open selected feels
            reactNibOpen[indexPath.section] = true
            let section = IndexSet.init(integer: indexPath.section)
            feedView.reloadSections(section, with: .none)
        }
        
        for i in 0..<reactNibOpen.count {
            if i != indexPath.section {
                if reactNibOpen[i] == true {
                    reactNibOpen[i] = false
                    let section = IndexSet.init(integer: i)
                    feedView.reloadSections(section, with: .fade)
                }
            }
        }
    }
}
