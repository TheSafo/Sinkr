//
//  GameViewController.swift
//  Sinkr
//
//  Created by Jake Saferstein on 6/19/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Firebase

class GameViewController : UIViewController {
    
    typealias CupData = (x: Double, y: Double)
//    let curCups 
    
//    let topRackVw = RackView(rack: rackForType(.ThreeTwoOne))
//    let botRackVw = RackView(rack: rackForType(.ThreeTwoOne))
    
//    let reRackTopBtn = UIButton(type: .System)
//    let reRackBotBtn = UIButton(type: .System)
    
    let gameRef: FIRDatabaseReference
    let playerName: String
    var otherName: String! = nil {
        didSet {
            if isPlayer1 {
                plyr1Lbl.text = playerName
                plyr2Lbl.text = otherName
            }
            else {
                plyr2Lbl.text = playerName
                plyr1Lbl.text = otherName
            }
        }
    }
    var isPlayer1 = true
    
    
    let plyr1Lbl    = UILabel()
    let plyr2Lbl    = UILabel()
    
    let score1Lbl   = UILabel()
    let score2Lbl   = UILabel()
    
    let cupBgVw = UIView()
    
    var cupVws: [UIView] = [] {
        willSet {
            for vw in cupVws {
                vw.removeFromSuperview()
            }
        }
        didSet {
            for vw in cupVws {
                self.cupBgVw.addSubview(vw)
            }
        }
    }

    init (gameCode: String, playerName: String) {
        
        self.gameRef = FIRDatabase.database().reference().child("games/\(gameCode)")
        self.playerName = playerName
        
        plyr1Lbl.text = playerName
        plyr2Lbl.text = "Loading..."
        
        super.init(nibName: nil, bundle: nil)
        
        setUpBothPlayers {
            print("all set up in reference to players")
            self.startUpdatingGameData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpBothPlayers(gotBothPlayers: () -> ()) {
        
        var otherPlayerName: String? = nil
        
        let submitUsrGroup = dispatch_group_create()
        dispatch_group_enter(submitUsrGroup)
        
        let playersRef = gameRef.child("players")
        playersRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            guard let players = snapshot.value as? [String] else {
                
                playersRef.setValue([self.playerName])
                dispatch_group_leave(submitUsrGroup)
                return
            }
            
            if players[0] != "" {
                self.isPlayer1 = false
                otherPlayerName = players[0]
                let newArr = [otherPlayerName!, self.playerName]
                playersRef.setValue(newArr)
            }
            else {
                playersRef.setValue([self.playerName])
            }
            
            dispatch_group_leave(submitUsrGroup)
        })
        
        
        
        dispatch_group_notify(submitUsrGroup, dispatch_get_main_queue()) {
            
            if let player2 = otherPlayerName {
                self.otherName = player2
                gotBothPlayers()
                return
            }
            else {
                
                let gotOtherPlayerGrp = dispatch_group_create()
                dispatch_group_enter(gotOtherPlayerGrp)
                let otherPlayerHandle = playersRef.observeEventType(.Value, withBlock: { (snapshot) in
                    
                    guard let players = snapshot.value as? [String] else {
                        print("IDK WHAT TO DO")
                        return
                    }
                    
                    if players.count > 1 {
                        self.otherName = players[1]
                        gotBothPlayers()
                        dispatch_group_leave(gotOtherPlayerGrp)
                    }
                })
                
                dispatch_group_notify(gotOtherPlayerGrp, dispatch_get_main_queue()) {
                    playersRef.removeObserverWithHandle(otherPlayerHandle)
                }
            }
        }
    }
    
    func startUpdatingGameData() {
        
        let cupsRef = gameRef.child("cups")
        cupsRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            guard let cups = snapshot.value as? [[String:NSNumber]] else {
                
                print("Error reading cups: \(snapshot.value)")
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.drawCups(cups)
            })
        })
        
        let scoresRef = gameRef.child("scores")
        scoresRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            guard let scores = snapshot.value as? [NSNumber] else {
                
                print("Error reading scores: \(snapshot.value)")
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.score1Lbl.text = "\(scores[0].integerValue)"
                self.score2Lbl.text = "\(scores[1].integerValue)"
            })
        })
        
        let turnRef = gameRef.child("turn")
        turnRef.observeEventType(.Value, withBlock: { (snapshot) in
            
            guard let turn = (snapshot.value as? NSNumber)?.integerValue else {
                
                print("Error reading scores: \(snapshot.value)")
                return
            }
            
            if turn == 0 {
                dispatch_async(dispatch_get_main_queue(), {
                    self.plyr1Lbl.backgroundColor = .yellowColor()
                    self.plyr2Lbl.backgroundColor = .whiteColor()
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.plyr1Lbl.backgroundColor = .whiteColor()
                    self.plyr2Lbl.backgroundColor = .yellowColor()
                })
            }
        })
    }
    
    func drawCups(cups: [[String:NSNumber]]) {
        
        guard cups.count > 0 else {
            
            print("NO CUPS LEFT!!!")
            return
        }
        
        var asStructs = cups.map { (dict) -> CupData in
            var data: CupData = (x: dict["x"]!.doubleValue, y: dict["y"]!.doubleValue)
            return data
        }
        
        var lowestXInd = 0
        var lowestYInd = 0
        var maxXInd = 0
        var maxYInd = 0

        for i in 1..<asStructs.count {
            let cup = asStructs[i]
            
            let lowestXCup = asStructs[lowestXInd]
            let lowestYCup = asStructs[lowestYInd]
            
            let maxXCup = asStructs[maxXInd]
            let maxYCup = asStructs[maxYInd]
            
            if cup.y < lowestYCup.y {
                lowestYInd = i
            }
            if cup.x < lowestXCup.x {
                lowestXInd = i
            }
            if cup.y > maxYCup.y {
                maxYInd = i
            }
            if cup.x > maxXCup.x {
                maxXInd = i
            }
        }
        
        let bgW = cupBgVw.bounds.width
        let bgH = cupBgVw.bounds.height
        
        let cupW = bgW/3.0
        let cupH = bgH/3.0
        
        let lowestX = asStructs[lowestXInd].x
        let lowestY = asStructs[lowestYInd].y
        let maxX = asStructs[maxXInd].x - lowestX //+ cupW/2.0
        let maxY = asStructs[maxYInd].y - lowestY //+ cupH/2.0
        
        for i in 0..<asStructs.count {
            asStructs[i].x += -lowestX //+ cupW/2.0
            asStructs[i].y += -lowestY //+ cupH/2.0
        }
        
        for i in 0..<asStructs.count {
            asStructs[i].x /= maxX
            asStructs[i].y /= maxY
        }
        

        
        let vws = asStructs.map { (c) -> UIView in
            let v = UIView()
            v.frame = CGRect(x: (CGFloat(c.x) * (bgW - CGFloat(cupW))) - CGFloat(cupW)/2, y: (bgH - CGFloat(cupH)) - CGFloat(cupH)/2, width: CGFloat(cupW), height: CGFloat(cupH))
//            v.frame = CGRect(x: CGFloat(c.x), y: CGFloat(c.y), width: CGFloat(cupW), height: CGFloat(cupH))
            v.layer.borderWidth = 1
            v.backgroundColor = .redColor()
            v.layer.cornerRadius = CGFloat(cupW/2.0)
            return v
        }
        
        self.cupVws = vws
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure Subviews
        view.backgroundColor = UIColor.whiteColor()
        
//
//        topRackVw.makeTopRack()
        
        plyr1Lbl.textAlignment = .Center
        plyr1Lbl.backgroundColor = UIColor.yellowColor()
        plyr1Lbl.font = UIFont.boldSystemFontOfSize(26)
        plyr1Lbl.adjustsFontSizeToFitWidth = true
        plyr1Lbl.layer.cornerRadius = 17
        plyr1Lbl.clipsToBounds = true
        
        plyr2Lbl.textAlignment = .Center
        plyr2Lbl.layer.cornerRadius = 17
        plyr2Lbl.font = UIFont.boldSystemFontOfSize(26)
        plyr2Lbl.adjustsFontSizeToFitWidth = true
        plyr2Lbl.clipsToBounds = true

        score1Lbl.textAlignment = .Center
        score1Lbl.text = "0"
        score1Lbl.font = UIFont.boldSystemFontOfSize(32)
        score1Lbl.textColor = .redColor()
        
        score2Lbl.textAlignment = .Center
        score2Lbl.text = "0"
        score2Lbl.font = UIFont.boldSystemFontOfSize(32)
        score2Lbl.textColor = .redColor()
        
        cupBgVw.layer.borderWidth = 1
        
//        reRackTopBtn.setImage(UIImage(named: "rearrange"), forState: .Normal)
//        reRackTopBtn.addTarget(self, action: #selector(rerackTopPressed), forControlEvents: .TouchUpInside)
//        reRackTopBtn.tintColor = UIColor.blackColor()
//        
//        reRackBotBtn.setImage(UIImage(named: "rearrange"), forState: .Normal)
//        reRackBotBtn.addTarget(self, action: #selector(rerackBotPressed), forControlEvents: .TouchUpInside)
//        reRackBotBtn.tintColor = UIColor.blackColor()

        //Add Subviews
        view.addSubview(plyr1Lbl)
        view.addSubview(plyr2Lbl)
        view.addSubview(score1Lbl)
        view.addSubview(score2Lbl)
        view.addSubview(cupBgVw)
//        view.addSubview(topRackVw)
//        view.addSubview(botRackVw)
//        view.addSubview(reRackTopBtn)
//        view.addSubview(reRackBotBtn)
        
        //Add Constraints
        plyr1Lbl.snp_makeConstraints { (make) in
            make.bottom.equalTo(view).inset(40)
            make.left.equalTo(view).inset(15)
            make.right.equalTo(view.snp_centerX).inset(10)
            make.height.equalTo(60)
        }
        plyr2Lbl.snp_makeConstraints { (make) in
            make.bottom.equalTo(view).inset(40)
            make.right.equalTo(view).inset(15)
            make.left.equalTo(view.snp_centerX).offset(10)
            make.height.equalTo(60)
        }
        score1Lbl.snp_makeConstraints { (make) in
            make.bottom.equalTo(view).inset(5)
            make.centerX.width.equalTo(plyr1Lbl)
            make.top.equalTo(plyr1Lbl.snp_bottom)
        }
        score2Lbl.snp_makeConstraints { (make) in
            make.bottom.equalTo(view).inset(5)
            make.centerX.width.equalTo(plyr2Lbl)
            make.top.equalTo(plyr2Lbl.snp_bottom)
        }
        cupBgVw.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(20)
            make.bottom.equalTo(view.snp_centerY)
            make.width.equalTo(cupBgVw.snp_height)
        }
//        topRackVw.snp_makeConstraints { (make) in
//            make.width.height.equalTo(RackView.rackWidth)
//            make.centerX.equalTo(view)
//            make.top.equalTo(25)
//        }
//        botRackVw.snp_makeConstraints { (make) in
//            make.width.height.equalTo(RackView.rackWidth)
//            make.centerX.equalTo(view)
//            make.bottom.equalTo(view).offset(-5)
//        }
//        reRackTopBtn.snp_makeConstraints { (make) in
//            make.width.height.equalTo(40)
//            make.right.equalTo(view).inset(20)
//            make.top.equalTo(view.snp_centerY).offset(-20)
//        }
//        reRackBotBtn.snp_makeConstraints { (make) in
//            make.width.height.equalTo(40)
//            make.left.equalTo(view).inset(20)
//            make.top.equalTo(view.snp_centerY).offset(20)
//        }
    }
    
    //MARK: Button Handlers
//    func rerackTopPressed() {
//        
//        self.createRackChoicesForRackView(self.topRackVw)
//    }
    
//    func rerackBotPressed() {
//        
//        self.createRackChoicesForRackView(self.botRackVw)
//    }
    
    func createRackChoicesForRackView(rackVw: RackView) {
        
        let validRacks = rackVw.rack.validRacksForCurrentCups()
        
        let actionSheet = UIAlertController(title: "Choose Rack", message: nil, preferredStyle: .ActionSheet)
        
        validRacks.forEach { (type) in
            
            let typeAction = UIAlertAction(title: nameForType(type), style: .Default) { (action) in
                
                rackVw.reRackToType(type)
            }
            actionSheet.addAction(typeAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        actionSheet.addAction(cancelAction)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
}
