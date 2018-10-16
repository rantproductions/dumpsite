//
//  ProfileViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 12/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {

    // Tag Views
    @IBOutlet var trashcanCollection: UICollectionView!
    
    // Temporary Data
    var count = 1
    
    // Deleting Trashcan
    var isInDeleteMode = false
    var isCellAddTrashcanButton = true
    
    var addTrashcanCell: AddTrashcanCell?
    var addTrashcanCellPath = IndexPath()
    
    var trashcans = [TrashcanCell]()
    
    // Gesture Recognizer
    var longPress: UILongPressGestureRecognizer!
    var doubleTap: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make navigation bar transparent
        makeNavigationBarTransparent()
        
        // Hide back button
        hideBackButton()

        // Register nibs to Trashcan Collection View
        registerNibs()
        
        setAddTrashcanCellPath()
        
        // Handle gestures
        handleGestures()
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
        addTrashcanCellPath = IndexPath(item: count, section: 0)
    }
    
    // Collection View Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count + 1
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
            print("Adding cell at: \(indexPath)") // debugging
            
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
                // Add 1 Trashcan
                count += 1
                
                // Insert Trashcan into Collection View
                addTrashcanCellPath = IndexPath(item: count, section: 0)
                collectionView.insertItems(at: [indexPath as IndexPath])
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
        count -= 1
        addTrashcanCellPath = IndexPath(item: count, section: 0)
        collectionView.deleteItems(at: [indexPath as IndexPath])
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
            }
            
            // Hide add trash can cell
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
            }
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
