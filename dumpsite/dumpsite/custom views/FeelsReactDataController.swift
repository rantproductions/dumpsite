//
//  FeelsReactDataController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 10/12/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class FeelsReactDataController: UIViewController {

    // Tag Views
    @IBOutlet var reactCount1Label: UILabel!
    @IBOutlet var reactCount2Label: UILabel!
    @IBOutlet var reactCount3Label: UILabel!
    @IBOutlet var reactCount4Label: UILabel!
    @IBOutlet var reactCount5Label: UILabel!
    
    // Data
    var reactionData: Reactions!
    var feelsCount = [Int]()
    var counter = [Int]()
    var currentCounter = 0
    
    var reactTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeRoundCorners()
        // getFeelsCount()
        // initializeCounters()
        // startReactCounter()
    }
    
    func commonInit(_ reactionData: Reactions) {
        self.reactionData = reactionData
    }
    
    func getFeelsCount() {
        for reaction in reactionData.reactions {
            let react = React(dictionary: reaction.value as! [String : Any])
            feelsCount.append(react!.reactCount)
            print(react!.reactCount)
        }
    }
    
    func initializeCounters() {
        counter.append(0)
        counter.append(0)
        counter.append(0)
        counter.append(0)
        counter.append(0)
    }
    
    func startReactCounter() {
        reactTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(displayCounters), userInfo: nil, repeats: true)
    }
    
    @objc func displayCounters() {
        if (counter[0] < feelsCount[0] + 1) || (counter[1] < feelsCount[1] + 1) || (counter[2] < feelsCount[2] + 1) || (counter[3] < feelsCount[3] + 1) || (counter[4] < feelsCount[4] + 1) {
            reactCount1Label.text = "\(counter[0])"
            reactCount2Label.text = "\(counter[1])"
            reactCount3Label.text = "\(counter[2])"
            reactCount4Label.text = "\(counter[3])"
            reactCount5Label.text = "\(counter[4])"
            
            for i in 0..<counter.count {
                if(counter[i] < feelsCount[i]) {
                    counter[i] += 1
                }
            }
            
        } else {
            reactTimer.invalidate()
        }
    }
    
    func makeRoundCorners() {
        reactCount1Label.layer.cornerRadius = 8
        reactCount1Label.clipsToBounds = true
        reactCount2Label.layer.cornerRadius = 8
        reactCount2Label.clipsToBounds = true
        reactCount3Label.layer.cornerRadius = 8
        reactCount3Label.clipsToBounds = true
        reactCount4Label.layer.cornerRadius = 8
        reactCount4Label.clipsToBounds = true
        reactCount5Label.layer.cornerRadius = 8
        reactCount5Label.clipsToBounds = true
    }

}
