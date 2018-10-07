//
//  NewFeelsViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 06/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class NewFeelsViewController: UIViewController {

    // Tag Views
    @IBOutlet var moodFrame: UIImageView!
    @IBOutlet var charCountLabel: UILabel!
    @IBOutlet var charCountSign: UILabel!
    @IBOutlet var feelsContent: FeelsTextView!
    @IBOutlet var btnDump: UIButton!
    
    @IBOutlet var emojiScroll: UIView!
    @IBOutlet var btnMood: UIButton!
    
    // Data
    var feelsContentHeight = CGFloat()
    
    // Flags
    var isEmojiViewOpened : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the Navigation Bar to transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // Stop back button from appearing
        self.navigationItem.leftItemsSupplementBackButton = false
        self.navigationItem.hidesBackButton = true
        
        // Round corners of Views
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
        
        // Set textView for feelsContent
        feelsContent.delegate = self
        feelsContent.isEditable = true
        feelsContentHeight = feelsContent.frame.size.height
        
        // Set placeholders for textView
        feelsContent.text = "Rant all you want!"
        feelsContent.textColor = UIColor.lightGray
        
        // Expand textView depending on text
        feelsContent.translatesAutoresizingMaskIntoConstraints = false
        feelsContent.isScrollEnabled = false
        
        // Set up emoji view
        emojiScroll.alpha = 0
    }
    
    func changeBtnMoodImage(choosenEmoji: String) {
        let btnImage = UIImage(named: choosenEmoji)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.btnMood.setImage(btnImage, for: .normal)
        })
        
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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
            feelsContent.text = "Rant all you want!"
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
