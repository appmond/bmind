//
//  ScoringViewController.swift
//  gametheory
//
//  Created by Edmond Osmani on 20/01/20.
//  Copyright © 2020 Edmond Osmani. All rights reserved.
//

import UIKit

class ScoringViewController: UITableViewController {
    
    var deviceNames:[String]?
    var deviceScores:[String]?
    let reuseIdentifier = "scoringCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (deviceNames?.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ScoringCell
        let cellDevice = deviceNames?[indexPath.item]
        let cellScore = deviceScores?[indexPath.item]
        cell.deviceName.text = cellDevice
        cell.deviceScore.text = cellScore
        if cellDevice == UIDevice.current.identifierForVendor?.uuidString {
            cell.deviceName.textColor = UIColor.red
            cell.deviceScore.textColor = UIColor.red
            cell.deviceScore.font = UIFont(name:"HelveticaNeue-Bold", size: 10.0)
            cell.deviceName.font = UIFont(name:"HelveticaNeue-Bold", size: 10.0)
        }
        if indexPath.item == 0 {
            cell.deviceScore.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
            cell.deviceName.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        }
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

}

class ScoringCell:UITableViewCell   {
    
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceScore: UILabel!

}
