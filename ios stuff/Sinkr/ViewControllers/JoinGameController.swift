//
//  JoinGameController.swift
//  Sinkr
//
//  Created by Jake Saferstein on 10/22/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class JoinGameController : UIViewController, UITextFieldDelegate {
    
    let name    = UITextField()
    let field   = UITextField()
    let enter   = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .whiteColor()
        
        name.placeholder = "Player Name"
        name.borderStyle = .Line
        name.returnKeyType = .Done
        
        field.placeholder = "Game Code"
        field.borderStyle = .Line
        field.returnKeyType = .Done
        field.keyboardType = .NumberPad
        
        enter.setTitle("Continue", forState: .Normal)
        enter.setTitleColor(.blueColor(), forState: .Normal)
        enter.addTarget(self, action: #selector(self.enterPressed), forControlEvents: .TouchUpInside)
        
        view.addSubview(name)
        view.addSubview(field)
        view.addSubview(enter)
        
        name.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.75)
            make.height.equalTo(40)
            make.bottom.equalTo(field.snp_top).offset(-15)
        }
        field.snp_makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.75)
            make.height.equalTo(40)
        }
        enter.snp_makeConstraints { (make) in
            make.centerX.equalTo(field)
            make.top.equalTo(field.snp_bottom).offset(15)
            make.width.equalTo(field)
            make.height.equalTo(50)
        }
    }
    
    func enterPressed() {
        
        guard let gameCode = field.text, playerName = name.text else  {
            
            return
        }
        
        //If enter is valid
        let nextCtrlr = GameViewController(gameCode: gameCode, playerName: playerName)
        self.presentViewController(nextCtrlr, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return false
    }

}
