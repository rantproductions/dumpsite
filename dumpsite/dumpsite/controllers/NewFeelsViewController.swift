//
//  NewFeelsViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 06/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit
import Firebase

class NewFeelsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // Tag Views
    @IBOutlet var moodFrame: UIImageView!
    @IBOutlet var charCountLabel: UILabel!
    @IBOutlet var charCountSign: UILabel!
    @IBOutlet var feelsContent: FeelsTextView!
    @IBOutlet var btnDump: UIButton!
    
    @IBOutlet var btnChooseTrashcan: UIButton!
    @IBOutlet var trashcanName: UILabel!
    @IBOutlet var trashcanPicker: UIPickerView!
    
    @IBOutlet var emojiScroll: UIView!
    @IBOutlet var btnMood: UIButton!
    
    // References
    var firestoredb: Firestore!
    
    // Data
    var feelsContentHeight = CGFloat()
    var emojiViewController: EmojiViewController?
    var chosenEmoji = String()
    var emojiArray = ["051-confused", "051-greed", "051-shocked", "051-sick", "051-sleepy", "051-nerd", "051-muted", "051-surprised", "051-suspicious", "051-vain"]
    
    // Temporary
    var trashcanList = ["Mixed Emotions"]
    var trashcanCount = Int()
    
    // Flags
    var isEmojiViewOpened: Bool = false
    var isTrashcanPickerOpened: Bool = false
    
    // Inherited Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get firestore reference
        getFirestoreDatabase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the Navigation Bar to transparent
        makeNavigationBarTransparent()
        
        // Stop back button from appearing
        hideBackButton()
        
        // Make corners of views round
        makeCornersRound()
        
        // Set up trashcan picker view
        setUpTrashcanPicker()
        
        // Set up text view
        setUpFeelsContent()
        
        // Hide emoji options
        hideEmojiOptions()
        
        getChildControllers()
        emojiViewController?.moodDelegate = self
        
        // Miscs
        self.tabBarController?.tabBar.isHidden = true
        handleTap()
        moveViewWithKeyboard()
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
    
    func makeNavigationBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func hideBackButton() {
        self.navigationItem.leftItemsSupplementBackButton = false
        self.navigationItem.hidesBackButton = true
    }
    
    func makeCornersRound() {
        moodFrame.layer.cornerRadius = 15
        moodFrame.clipsToBounds = true
        btnDump.layer.cornerRadius = 12
        btnDump.clipsToBounds = true
        feelsContent.layer.cornerRadius = 8
        feelsContent.clipsToBounds = true
        charCountSign.layer.cornerRadius = 4
        charCountSign.clipsToBounds = true
        emojiScroll.layer.cornerRadius = 15
        emojiScroll.clipsToBounds = true
        btnChooseTrashcan.layer.cornerRadius = 12
        btnChooseTrashcan.clipsToBounds = true
    }
    
    func setUpTrashcanPicker() {
        self.trashcanPicker.delegate = self
        self.trashcanPicker.dataSource = self
        
        trashcanPicker.alpha = 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return trashcanCount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return trashcanList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Change button name to trashcan name
        trashcanName.text = trashcanList[row]
    }
    
    func setUpFeelsContent() {
        feelsContent.translatesAutoresizingMaskIntoConstraints = false
        feelsContentHeight = feelsContent.frame.size.height
        feelsContent.delegate = self
        feelsContent.isEditable = true
        feelsContent.text = "Come on. Rant!"
        feelsContent.textColor = UIColor.lightGray
        feelsContent.isScrollEnabled = false
    }
    
    func hideEmojiOptions() {
        emojiScroll.alpha = 0
    }
    
    func getChildControllers() {
        if let viewController = children.first as? EmojiViewController {
            emojiViewController = viewController
        }
    }
    
    @IBAction func chooseMood(_ sender: UIButton) {
        // Show emojiView
        if isEmojiViewOpened {
            UIView.animate(withDuration: 0.5, animations: {
                self.emojiScroll.alpha = 0
            })
            isEmojiViewOpened = false
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.emojiScroll.alpha = 1
            })
            isEmojiViewOpened = true
        }
    }
    
    @IBAction func dumpFeels(_ sender: UIButton) {
        // Check if feelsContent is empty
        if let content = feelsContent.text {
            if content ==  "Dump your feels and be free." { return }
            
            // Get trashcan name
            var trashcanName = self.trashcanName.text
            
            // If user didn't picked a trashcan, set it
            // to default "Mixed Emotions"
            if trashcanName == "Choose Trashcan" {
                trashcanName = "Mixed Emotions"
            }
            
            // Check if mood is empty
            if !emojiArray.contains(chosenEmoji) {
                chosenEmoji = emojiArray[0]
            }
            
            // Get current user's id
            let userId = Auth.auth().currentUser?.uid
            
            // Create new Feels
            let feels = Feels(userId: userId!, trashcan: trashcanName!, moodImage: chosenEmoji, content: content, timestamp: Timestamp.init())
            
            var feelsRef: DocumentReference? = nil
            feelsRef = self.firestoredb.collection("feels").addDocument(data: feels.dictionary) { err in
                if let err = err {
                    print("Error dumping! \(err.localizedDescription)")
                } else {
                    print("Your feels have been dumped! \(feelsRef!.documentID)")
                }
            }
            
            // Create reactions
            var reactNames = ["Happy", "Tease", "Crying", "Bored", "Angry"]
            var reactArray = [String: Any]()
            for i in 0..<reactNames.count {
                let react = React(reactName: reactNames[i], reactCount: 0, userIdList: [String]())
                reactArray.updateValue(react.dictionary, forKey: "react\(i)")
            }
            
            let reactions = Reactions(feelsId: feelsRef!.documentID, reactions: reactArray, timestamp: Timestamp.init())
            self.firestoredb.collection("reactions").document(feelsRef!.documentID).setData(reactions.dictionary, merge: true) { err in
                if let err = err {
                    print("Error adding reactions to feels! \(err.localizedDescription)")
                } else {
                    print("Successfully added reactions for \(feelsRef!.documentID) feels!")
                }
            }
            
            self.firestoredb.collection("users").document(userId!).getDocument() { (document, err) in
                if let err = err {
                    print(err.localizedDescription)
                } else {
                    if let document = document {
                        let userData = User(dictionary: document.data()!)
                        var feelsCount = userData!.feelsCount as Int
                        feelsCount += 1
                        
                        self.firestoredb.collection("users").document(userId!).updateData([
                            "feelsCount": feelsCount
                            ])
                    }
                }
            }
            // Push to feed view
            self.performSegue(withIdentifier: "afterDump", sender: nil)
        } else {
            let message = "Hey! You haven't expressed anything yet!"
            let deleteMessage = UIAlertController(title: "Huh?", message: message, preferredStyle: .alert)
            self.present(deleteMessage, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard self?.presentedViewController == deleteMessage else { return }
                    
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func chooseTrashcan(_ sender: UIButton) {
        if isTrashcanPickerOpened {
            UIView.animate(withDuration: 0.5, animations: {
                self.trashcanPicker.alpha = 0
                })
            isTrashcanPickerOpened = false
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.trashcanPicker.alpha = 1
            })
            isTrashcanPickerOpened = true
        }
    }
    
    // Miscs
    // Dismiss keyboard when users tap anywhere
    func handleTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Push view up when keyboard is obscuring textfield
    func moveViewWithKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 100
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height - 100
            }
        }
    }

}

 // Functions for TextView
extension NewFeelsViewController: UITextViewDelegate {
    // Track if user begins editing textView
    func textViewDidBeginEditing(_ textView: UITextView) {
        if feelsContent.textColor == UIColor.lightGray {
            feelsContent.text = nil
            feelsContent.textColor = UIColor.black
        }
    }
    
    // While user edits text
    func textViewDidChange(_ textView: UITextView) {
        // Display character count
        let charCount = feelsContent.text.count
        if charCount > 230 {
            charCountLabel.textColor = UIColor.orange
        } else {
            charCountLabel.textColor = UIColor.white
        }
        
        charCountLabel.text = "\(charCount)"
        
        // Expand textView base on size of content
        let tempSize = CGSize(width: textView.frame.size.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(tempSize)
        
        // Keep textView size until it needs to expand
        if estimatedSize.height > feelsContentHeight {
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
        
    }
    
    // Track if user finishes editing text
    func textViewDidEndEditing(_ textView: UITextView) {
        if feelsContent.text.isEmpty {
            feelsContent.text = "Dump your feels and be free."
            feelsContent.textColor = UIColor.lightGray
        }
    }
    
    // Limit number of characters
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 240
    }
}

extension NewFeelsViewController: MoodDelegate {
    func changeMoodImage(chosenEmoji: String) {
        self.chosenEmoji = chosenEmoji
        let btnImage = UIImage(named: chosenEmoji) as UIImage?
        btnMood.setImage(btnImage, for: .normal)
        print("Changing to \(chosenEmoji)")
    }
}
