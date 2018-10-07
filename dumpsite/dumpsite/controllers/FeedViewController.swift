//
//  FeedViewController.swift
//  dumpsite
//
//  Created by Elisha Saylon on 04/10/2018.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Tag Views
    @IBOutlet var feedView: UITableView!
    
    // Temporary Data
    let moodImageNames = ["051-angry", "051-cool", "051-happy-7", "051-serious", "051-sad"]
    var reactNibOpen = [false, false, false, false, false]
    
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
    
    // Returns number of Feel Cells
    func numberOfSections(in tableView: UITableView) -> Int {
        return moodImageNames.count
    }
    
    // Returns the number of rows under each Feel Cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if react is open, return the feelsCell and reactCell
        if reactNibOpen[section] == true {
            return 2
        }
        else { // else return the feelsCell only
            return 1
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
            cell.commonInit(moodImageNames[indexPath.section])
            
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
