//
//  FeedViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 04/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, UIGestureRecognizerDelegate {

    // Tag Views
    @IBOutlet var feedView: UITableView!
    @IBOutlet var noFeelsLabel: UILabel!
    
    // Feed View Data
    var listenToFeels: Bool = true
    var reactNibOpen = [Bool]()
    var feelsArray = [Feels]()
    var feelsIds = [String]()
    var reactionsArray = [Reactions]()
    
    var currentReact: Int!
    var selectedRow: Int!
    var index = 0
    
    // Data for other View
    var currentUserData: User!
    var userId: String!
    var trashcanCount = Int()
    var trashcanList = [String]()
    
    // Gesture Recognizer
    var longPress: UILongPressGestureRecognizer!
    var isLongPress = false

    // Firebase References
    var firestoredb: Firestore!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getFirestoreDatabase()
        getCurrentUser()
        getCurrentUserData()
        getTrashcanList()
        checkForUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        listenToFeels = false
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
        
        // Show tab bar
        self.tabBarController?.tabBar.isHidden = false
        
        // Set up Feed View's data source and delegate
        feedView.dataSource = self
        feedView.delegate = self
        
        self.tabBarController?.delegate = self
        
        // Add blank space at the bottom of Feed View table
        let feedViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        feedView.contentInset = feedViewInsets
        
        // Fix table cell expand glitch
        feedView.rowHeight = UITableView.automaticDimension
        feedView.estimatedRowHeight = 160
        
        feedView.estimatedSectionHeaderHeight = 0
        feedView.estimatedSectionFooterHeight = 0
        
        // Set up Feels Cell and React Cell
        let feelsCell = UINib(nibName: "FeelsCell", bundle: nil)
        let reactCell = UINib(nibName: "ReactCell", bundle: nil)
        
        // Register custom nib, the Feels Cell and React Cell
        feedView.register(feelsCell, forCellReuseIdentifier: "feelsCell")
        feedView.register(reactCell, forCellReuseIdentifier: "reactCell")
        
        handleGestures()
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
    
    func loadFeels() {
        firestoredb.collection("feels").order(by: "timestamp", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error fetching feels! \(err.localizedDescription)")
            } else {
                // Check if there's no Feels
                if let querySnapshot = querySnapshot {
                    self.noFeelsLabel.isHidden = true
                    self.feelsArray = querySnapshot.documents.compactMap({document in Feels(dictionary: document.data())})
                    for _ in 0..<querySnapshot.count {
                        self.reactNibOpen.append(false)
                    }
                    
                } else {
                    self.noFeelsLabel.isHidden = false
                }
                
                // Reload feed view
                DispatchQueue.main.async {
                    self.feedView.reloadData()
                }
            }
            
        }
    }
    
    func loadReacts() {
        firestoredb.collection("reactions").order(by: "timestamp", descending: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error fetching reacts! \(err.localizedDescription)")
                } else {
                    if let querySnapshot = querySnapshot {
                        self.reactionsArray = querySnapshot.documents.compactMap({document in Reactions(dictionary: document.data())})
                    } else {
                        print("Reactions not fetched.")
                    }
                }
        }
    }
    
    func checkForUpdates() {
        let feelsListener = firestoredb.collection("feels").order(by: "timestamp", descending: true)
            .addSnapshotListener() { (querySnapshot, err) in
                guard let querySnapshot = querySnapshot else { return }
                querySnapshot.documentChanges.forEach { diff in
                    let feels = Feels(dictionary: diff.document.data())!
                    if feels.userId != self.userId {
                        self.feelsIds.insert(diff.document.documentID, at: 0)
                        self.feelsArray.insert(Feels(dictionary: diff.document.data())!, at: 0)
                        self.reactNibOpen.insert(false, at: 0)
                    }
                    
                    if diff.type == .added {
                        self.feelsIds.append(diff.document.documentID)
                        self.feelsArray.append(Feels(dictionary: diff.document.data())!)
                        self.reactNibOpen.append(false)
                    } else if diff.type == .removed {
                        self.feelsIds.remove(at: self.index)
                        self.feelsArray.remove(at: self.index)
                        self.reactNibOpen.remove(at: self.index)
                    }
                    
                    self.index += 0
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
                        self.reactionsArray[self.currentReact] = Reactions(dictionary: diff.document.data())!
                    } else if diff.type == .added {
                        self.reactionsArray.append(Reactions(dictionary: diff.document.data())!)
                    } else if diff.type == .removed {
                        self.reactionsArray.remove(at: self.index)
                    }
                }
                
                self.index += 0
                DispatchQueue.main.async {
                    self.feedView.reloadData()
                }
        }
        
        if !listenToFeels {
            feelsListener.remove()
            reactsListener.remove()
        }
    }
    
    // Returns number of Feel Cells
    func numberOfSections(in tableView: UITableView) -> Int {
        return feelsArray.count
    }
    
    // Returns the number of rows under each Feel Cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reactNibOpen[section] == false { // else return the feelsCell only
            return 1
        }
        else { // if react is open, return the feelsCell and reactCell
            return 2
        }
    }
    
    // Return the cell to use for each row
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
            // currentReact = indexPath.section
            
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
    
    // What happens when a section, feelsCell, is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.section
        
        if isLongPress {
            isLongPress = false
            return
        }
        
        if reactNibOpen[indexPath.section] == true {
            reactNibOpen[indexPath.section] = false
            currentReact = indexPath.section
            
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
    
    func getCurrentUserData() {
        firestoredb.collection("users").document(userId)
            .addSnapshotListener() { (querySnapshot, err) in
                guard let querySnapshot = querySnapshot else { return }
                self.currentUserData = User(dictionary: querySnapshot.data()!)
                print(self.currentUserData)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.isKind(of: UINavigationController.self as AnyClass) {
            let navController = tabBarController.viewControllers![1] as! UINavigationController
            let destinationController = navController.topViewController as! ProfileViewController
            destinationController.currentUserData = currentUserData
        }
    }
    
    func getTrashcanList() {
        let userRef = firestoredb.collection("users").document(userId)
        
        userRef.getDocument() { (document, err) in
            // Check for error
            if let err = err {
                print("Error fetching user document. \(err.localizedDescription)")
            } else {
                // Check if document is not empty
                if let document = document, document.exists {
                    self.currentUserData = User(dictionary: document.data()!)
                    print(self.currentUserData)
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
    
    func handleGestures() {
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.25
        longPress.delegate = self
        
        feedView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress() {
        isLongPress = true
        
        let feelsReactData = FeelsReactDataController()
        feelsReactData.commonInit(reactionsArray[selectedRow])
        self.navigationController?.pushViewController(feelsReactData, animated: true)
        feelsReactData.getFeelsCount()
        feelsReactData.initializeCounters()
        feelsReactData.startReactCounter()
    }
}
