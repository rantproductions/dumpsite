//
//  FeedViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 04/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Tag Views
    @IBOutlet var feedView: UITableView!
    
    // Feed View Data
    var reactNibOpen = [Bool]()
    var feelsArray = [Feels]()
    var reactionsArray = [String: React]()
    
    var feelsStack = FeelsStack()
    
    // Data for NewFeelsViewController
    var trashcanCount = Int()
    var trashcanList = [String]()
    
    // Firebase References
    var firestoredb: Firestore!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get firestore reference
        getFirestoreDatabase()
        
        getTrashcanList()
        // loadFeels()
        checkForUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Set the Navigation Bar to transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // Stop back button from appearing
        self.navigationItem.leftItemsSupplementBackButton = false
        self.navigationItem.hidesBackButton = true
        
        // Set up Feed View's data source and delegate
        feedView.dataSource = self
        feedView.delegate = self
        
        // Add blank space at the bottom of Feed View table
        let feedViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        feedView.contentInset = feedViewInsets
        
        // Fix table cell expand glitch
        feedView.estimatedRowHeight = 0
        feedView.estimatedSectionHeaderHeight = 0
        feedView.estimatedSectionFooterHeight = 0
        
        // Set up Feels Cell and React Cell
        let feelsCell = UINib(nibName: "FeelsCell", bundle: nil)
        let reactCell = UINib(nibName: "ReactCell", bundle: nil)
        
        // Register custom nib, the Feels Cell and React Cell
        feedView.register(feelsCell, forCellReuseIdentifier: "feelsCell")
        feedView.register(reactCell, forCellReuseIdentifier: "reactCell")
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
    
    func loadFeels() {
        firestoredb.collection("feels").order(by: "timestamp", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error fetching feels! \(err.localizedDescription)")
            } else {
                // Check if there's no Feels
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        print("Feels ID: \(document.documentID)")
                        
                        let userId = document.data()["userId"] as! String
                        let trashcan = document.data()["trashcan"] as! String
                        let timestamp = document.data()["timestamp"] as! Timestamp
                        let moodImage = document.data()["moodImage"] as! String
                        let content = document.data()["content"] as! String
                        
                        let feels = Feels(userId: userId, trashcan: trashcan, moodImage: moodImage, content: content, timestamp: timestamp)
                        self.feelsArray.append(feels)
                        self.reactNibOpen.append(false)
                    }
                }
                
                // Reload feed view
                DispatchQueue.main.async {
                    self.feedView.reloadData()
                }
            }
            
        }
    }
    
    func checkForUpdates() {
        firestoredb.collection("feels").order(by: "timestamp", descending: true)
            .addSnapshotListener() { (querySnapshot, err) in
                guard let querySnapshot = querySnapshot else { return }
                querySnapshot.documentChanges.forEach { diff in
                    // New Dump
                    if diff.type == .added {
                        self.feelsArray.append(Feels(dictionary: diff.document.data())!)
                        // self.feelsStack.push(Feels(dictionary: diff.document.data())!)
                        self.reactNibOpen.append(false)
                        
                        DispatchQueue.main.async {
                            self.feedView.reloadData()
                        }
                    }
                }
        }
    }
    
    // Returns number of Feel Cells
    func numberOfSections(in tableView: UITableView) -> Int {
        return feelsArray.count
        // return feelsStack.count()
    }
    
    // Returns the number of rows under each Feel Cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if react is open, return the feelsCell and reactCell
        if reactNibOpen[section] == false {
            return 1
        }
        else { // else return the feelsCell only
            return 2
        }
    }
    
    // Returns height of each cell in a row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { // if feelsCell
            return 150
        }
        else { // if reactCell
            return 90
        }
    }
    
    // Return the cell to use for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // feelsCell always index 0
        if indexPath.row == 0 {
            let cell = feedView.dequeueReusableCell(withIdentifier: "feelsCell") as! FeelsCell
            let feels = feelsArray[indexPath.section]
            // let feels = feelsStack.pop()
            cell.commonInit(feels.moodImage, feels.content, feels.userId, feels.trashcan, feels.timestamp)
            
            // Make background of custom cell transparent
            cell.backgroundColor = .clear
            cell.backgroundView = UIView()
            cell.selectedBackgroundView = UIView()
            return cell
        } else {
            // the rest of the cells under the feelsCell
            let cell = feedView.dequeueReusableCell(withIdentifier: "reactCell") as! ReactCell
            
            // Make background of custom cell transparent
            cell.backgroundColor = .clear
            cell.backgroundView = UIView()
            cell.selectedBackgroundView = UIView()
            return cell
        }
    }
    
    // What happens when a section, feelsCell, is selected
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
    }
    
    func getTrashcanList() {
        let userId = Auth.auth().currentUser?.uid
        let userRef = firestoredb.collection("users").document(userId!)
        
        userRef.getDocument() { (document, err) in
            // Check for error
            if let err = err {
                print("Error fetching user document. \(err.localizedDescription)")
            } else {
                // Check if document is not empty
                if let document = document, document.exists {
                    for data in document.data()! {
                        if data.key == "trashcanCount" {
                            self.trashcanCount = data.value as! Int
                        }
                        
                        if data.key == "trashcans" {
                            self.trashcanList = data.value as! [String]
                        }
                    }
                } else {
                    print("Document doesn't exist!")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newFeelsViewController = segue.destination as! NewFeelsViewController
        newFeelsViewController.trashcanCount = self.trashcanCount
        newFeelsViewController.trashcanList = self.trashcanList
    }
    
    @IBAction func createFeels(_ sender: Any) {
        performSegue(withIdentifier: "newFeels", sender: nil)
    }
}
