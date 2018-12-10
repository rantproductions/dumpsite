//
//  ProfileViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 12/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate {

    // Firestore References
    var firestoredb: Firestore!
    
    // Tag Views
    @IBOutlet var trashcanCollection: UICollectionView!
    @IBOutlet var feelsCountLabel: UILabel!
    @IBOutlet var logoutBtn: UIButton!
    
    // Data
    var currentUserData: User!
    var feelsCount: Int!
    var trashcanCount: Int!
    var trashcanList: [String]!
    
    var feelsCountTimer: Timer!
    var count: Int = 0
    
    // Deleting Trashcan
    var isInDeleteMode = false
    var isCellAddTrashcanButton = true
    
    // Trashcan Data
    var addTrashcanCell: AddTrashcanCell?
    var addTrashcanCellPath = IndexPath()
    var trashcans = [TrashcanCell]()
    
    // Trashcan Alert Views
    var namePrompt: UIAlertController!
    var trashcanNameTf: UITextField!
    
    // Gesture Recognizer
    var longPress: UILongPressGestureRecognizer!
    var doubleTap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFirestoreDatabase()
        setCurrentUserData()
        
        makeNavigationBarTransparent()
        hideBackButton()
        
        registerNibs()
        makeRoundCorners()
        setAddTrashcanCellPath()
        
        handleGestures()
        
        setUpFeelsCounter()
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
    
    func setCurrentUserData() {
        trashcanList = currentUserData.trashcans
        trashcanCount = currentUserData.trashcanCount
        feelsCount = currentUserData.feelsCount
    }

    func makeNavigationBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func hideBackButton() {
        self.navigationItem.leftItemsSupplementBackButton = false
        self.navigationItem.hidesBackButton = true
    }
    
    func registerNibs() {
        let addTrashcanCell = UINib(nibName: "AddTrashcanCell", bundle: nil)
        let trashcanCell = UINib(nibName: "TrashcanCell", bundle: nil)
        
        trashcanCollection.register(addTrashcanCell, forCellWithReuseIdentifier: "addTrashcanCell")
        trashcanCollection.register(trashcanCell, forCellWithReuseIdentifier: "trashcanCell")
    }
    
    func makeRoundCorners() {
        logoutBtn.layer.cornerRadius = 6
        logoutBtn.clipsToBounds = true
    }
    
    // Set initial indexPath of add trash can button
    func setAddTrashcanCellPath() {
        addTrashcanCellPath = IndexPath(item: trashcanCount, section: 0)
    }
    
    func setUpFeelsCounter() {
        feelsCountTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(feelsCounter), userInfo: nil, repeats: true)
    }
    
    @objc func feelsCounter() {
        if count < feelsCount + 1 {
            feelsCountLabel.text = "\(count)"
            count += 1
        } else {
            feelsCountTimer.invalidate()
        }
    }
    
    // Collection View Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trashcanCount + 1
    }
    
    // Renders cell per indexPath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Return cell base on item no. The very first shell should be an Add Trashcan Button
        if  indexPath.item == addTrashcanCellPath.item {
            let cell = trashcanCollection.dequeueReusableCell(withReuseIdentifier: "addTrashcanCell", for: indexPath) as! AddTrashcanCell
            
            // Reference for AddTrashcanCell
            addTrashcanCell = cell
            return cell
        } else { // The rest of the cells are the users' existing Trashcan
            let cell = trashcanCollection.dequeueReusableCell(withReuseIdentifier: "trashcanCell", for: indexPath) as! TrashcanCell
            cell.commonInit(trashcanList[indexPath.item])
            cell.setUpTrashcanName()
            print("Passing data \(trashcanList[indexPath.item])")
            
            // Reference for Trashcan Cells
            trashcans.append(cell)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Separate functions for 2 Custom Cells
        if indexPath.item == addTrashcanCellPath.item { // Add Trashcan Cell
            // Check if Collection View is in Normal/Delete Mode
            if !isInDeleteMode { // Normal
                namePrompt = UIAlertController(title: "New Trashcan", message: "Sort your feelings well and give it a good name!", preferredStyle: .alert)
                namePrompt.addTextField { (textField: UITextField!) in
                    textField.placeholder = "Feels Be With You"
                    self.trashcanNameTf = textField
                    self.trashcanNameTf.delegate = self
                }
                
                namePrompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                namePrompt.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action: UIAlertAction) in
                    if let name = self.namePrompt.textFields?.first?.text {
                        self.trashcanCount += 1
                        self.trashcanList.append(name)
                        
                        self.firestoredb.collection("users").document(self.currentUserData.userId).updateData([
                            "trashcanCount": self.trashcanCount,
                            "trashcans": self.trashcanList
                            ])
                        
                        self.addTrashcanCellPath = IndexPath(item: self.trashcanCount, section: 0)
                        collectionView.insertItems(at: [indexPath as IndexPath])
                    }
                }))
                
                namePrompt.actions[1].isEnabled = false
                self.present(namePrompt, animated: true, completion: nil)
            }
        } else { // Trashcan Cell
            // Check if Collection View is in Normal/Delete Mode
            if !isInDeleteMode { // Normal
                print("Open Trashcan")
                showTrashcanContents(indexPath: indexPath)
            } else { // Delete Mode
                print("Deleting Trashcan #\(indexPath.item)")
                deleteTrashcan(collectionView: collectionView, indexPath: indexPath)
            }
        }
    }
    
    // Show contents of trashcan
    func showTrashcanContents(indexPath: IndexPath) {
        let trashcanContents = TrashcanContentViewController()
        trashcanContents.commonInit(trashcanList[indexPath.item])
        self.navigationController?.pushViewController(trashcanContents, animated: true)
        // trashcanContents.segregateFeels()
        trashcanCollection.deselectItem(at: indexPath, animated: true)
    }
    
    func deleteTrashcan(collectionView: UICollectionView, indexPath: IndexPath) {
        var message = "Deleting a trashcan will delete all feels dumped in it!"
        
        let deleteConfirmation = UIAlertController(title: "Delete Trashcan?", message: message, preferredStyle: .alert)
        deleteConfirmation.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        deleteConfirmation.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction) in
            var feelsToRemove = [String]()
            self.firestoredb.collection("feels").getDocuments() { (documents, err) in
                if let err = err {
                    print(err.localizedDescription)
                } else {
                    guard let documents = documents else { return }
                    for document in documents.documents {
                        let feels = Feels(dictionary: document.data())!
                        if feels.userId == self.currentUserData.userId {
                            print(indexPath.item)
                            print(self.trashcanList.count)
                            if feels.trashcan == self.trashcanList[indexPath.item] {
                                feelsToRemove.append(document.documentID)
                            }
                        }
                    }
                    
                    for documentId in feelsToRemove {
                        self.firestoredb.collection("feels").document(documentId).delete()
                        self.firestoredb.collection("reactions").document(documentId).delete()
                    }
                    
                    self.trashcanCount -= 1
                    self.trashcanList.remove(at: indexPath.item)
                    
                    self.firestoredb.collection("users").document(self.currentUserData.userId).updateData([
                        "trashcanCount": self.trashcanCount,
                        "trashcans": self.trashcanList
                        ])
                    
                    self.addTrashcanCellPath = IndexPath(item: self.trashcanCount, section: 0)
                    collectionView.deleteItems(at: [indexPath as IndexPath])
                    
                    message = "Good to know you are free from these feels!"
                    let deleteMessage = UIAlertController(title: "Trashcan Deleted", message: message, preferredStyle: .alert)
                    self.present(deleteMessage, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                            guard self?.presentedViewController == deleteMessage else { return }
                            
                            self?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }))
        present(deleteConfirmation, animated: true, completion:  nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 18
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        namePrompt.actions[1].isEnabled = (newString.length > 0 && newString.length <= maxLength)
        print(newString.length > 0 && newString.length <= maxLength)
        
        return newString.length <= maxLength
    }
    
    
    @IBAction func logoutUser(_ sender: UIButton) {
        do { try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    }
    
    // Gesture Functions
    func handleGestures() {
        // Create a var that will hold the gesture recognizers
        // Long press
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        // Double tap
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        
        // Add gesture recognizer to collection view
        trashcanCollection.addGestureRecognizer(longPress)
        
        // Add gesture recognizer to view
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(doubleTap)
    }
    
    // Starts delete mode
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer!) {
        if !isInDeleteMode {
            print("Entering delete mode!") // debugging
            
            // If gesture is not finished, return
            if gesture.state != .ended {
                return
            }
            
            // Set state of delete mode
            isInDeleteMode = true
            
            // Show delete button on every trashcan
            for trashcan in trashcans {
                trashcan.btnDelete.isHidden = false
                trashcan.shakeCell()
            }
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            addTrashcanCell?.isHidden = true
        }
    }

    // Stops delete mode
    @objc func handleDoubleTap(gesture: UITapGestureRecognizer!) {
        if isInDeleteMode {
            print("Stopping delete mode!") // debugging
            
            // Stop delete mode
            isInDeleteMode = false
            
            // Remove delete buttons and show add button
            for trashcan in trashcans {
                trashcan.btnDelete.isHidden = true
                trashcan.stopShake()
            }
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            addTrashcanCell?.isHidden = false
        }
    }
    
    // Handles whether functions for gesture shall happen base on what view is touched
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // If user is touching the cells, return false. Else allow gesture
        if (touch.view?.isKind(of: TrashcanCell.self))! && (touch.view?.isKind(of: AddTrashcanCell.self))! {
            return false
        }
        return true
    }
}
