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
        trashcanContents.commonInit(indexPath.item + 1)
        self.navigationController?.pushViewController(trashcanContents, animated: true)
        trashcanCollection.deselectItem(at: indexPath, animated: true)
    }
    
    func deleteTrashcan(collectionView: UICollectionView, indexPath: IndexPath) {
        trashcanCount -= 1
        trashcanList.remove(at: indexPath.item)
        
        firestoredb.collection("users").document(currentUserData.userId).updateData([
            "trashcanCount": trashcanCount,
            "trashcans": trashcanList
            ])
        
        addTrashcanCellPath = IndexPath(item: trashcanCount, section: 0)
        collectionView.deleteItems(at: [indexPath as IndexPath])
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
