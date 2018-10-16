//
//  EmojiViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 07/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class EmojiViewController: UIViewController {
    // TempData
    var emojis = ["051-confused", "051-greed", "051-shocked", "051-sick", "051-sleepy", "051-nerd", "051-muted", "051-surprised", "051-suspicious", "051-vain"]
    var emojiScrollSize = CGFloat()
    
    weak var moodDelegate: MoodDelegate?
    
    // Tag Views
    @IBOutlet var emojiScroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Enable scroll of emoji view
        emojiScroll.isScrollEnabled = true
        emojiScroll.isUserInteractionEnabled = true
        
        // Dynamically create emoji buttons
        createEmojiBtns()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createEmojiBtns() {
        // Create emoji buttons programmatically
        let btnSize = CGFloat(40)
        let btnX = CGFloat(emojiScroll.frame.midX - (btnSize / 2)) // location of buttons
        var btnY = CGFloat(0)
        
        // Loop through the emojis data and create a button for each
        for i in 0..<emojis.count {
            let emojiBtn = UIButton()
            
            if i == 0 { // For y location
                btnY = btnY + 15
                emojiScrollSize += btnY
            } else {
                btnY = btnY + btnSize + 15
                emojiScrollSize += 15
            }
            
            // Set size and position
            emojiBtn.frame = CGRect(x: btnX, y: btnY, width: btnSize, height: btnSize)
            emojiBtn.backgroundColor = UIColor.clear
            
            // Set image
            let btnImg = UIImage(named: emojis[i]) as UIImage?
            emojiBtn.setImage(btnImg, for: .normal)
            emojiBtn.setTitle(emojis[i], for: .normal)
            
            // Set function
            emojiBtn.addTarget(self, action: #selector(chooseEmoji), for: .touchUpInside)
            
            // Add to scrollView
            emojiScroll.addSubview(emojiBtn)
            
            // Adjust scrollView size
            emojiScrollSize += btnSize
            if i == emojis.count - 1 {
                emojiScrollSize += btnSize + 15
            }
            
            emojiScroll.contentSize = CGSize(width: emojiScroll.frame.size.width, height: emojiScrollSize)
        }
    }
    
    // Function assigned to each Emoji button created
    @objc func chooseEmoji(_ sender: UIButton) {
        var chosenEmoji = sender.currentTitle!
        print(chosenEmoji)
        
        if !chosenEmoji.isEmpty {
            moodDelegate?.changeMoodImage(chosenEmoji: chosenEmoji)
            chosenEmoji = String()
        }
    }
    
    func changBtnMoodImage(choosenEmoji: String) {
        let newFeelsViewController = parent as! NewFeelsViewController
        
        let btnImage = UIImage(named: choosenEmoji) as UIImage?
        newFeelsViewController.btnMood.setImage(btnImage, for: .normal)
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
