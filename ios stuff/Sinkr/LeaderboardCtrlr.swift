//
//  LeaderboardCtrlr.swift
//  Sinkr
//
//  Created by Jake Saferstein on 10/23/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Firebase

class LeaderboardCtrlr : UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
    }
}
