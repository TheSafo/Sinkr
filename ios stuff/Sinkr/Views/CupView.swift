//
//  CupView.swift
//  Sinkr
//
//  Created by Jake Saferstein on 6/18/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation
import UIKit

protocol CupViewDelegate {
    
    func cupViewTapped(cupVw: CupView)
}

class CupView : UIView {
    
    static var cupWidthHeight: CGFloat {
        get {
            let cupWidth = (RackView.rackWidth - cupPadding*3)/4
            return cupWidth
        }
    }
        
    var index: Index
    var status: CupStatus {
        didSet {
            self.updateCupForCurrentStatus()
        }
    }
    
    var delegate: CupViewDelegate? = nil
    
    init(index: Index, status: CupStatus) {
        self.index = index
        self.status = status
        super.init(frame: CGRectZero)
        
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(self.cupTapped(_:)))
        tapGr.numberOfTapsRequired = 1
        tapGr.numberOfTouchesRequired = 1
        self.addGestureRecognizer(tapGr)
        
        self.layer.cornerRadius = CupView.cupWidthHeight/2
        self.layer.borderWidth = 2

        self.updateCupForCurrentStatus()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCupForCurrentStatus() {
        
        switch status {
            
        case .DNE:
            self.hidden = true

        case .Full:
            self.backgroundColor = UIColor.redColor()

        case .Hit:
            self.backgroundColor = UIColor.greenColor()
        }
    }
    
    //MARK: Button handling
    func cupTapped(tapGR : UITapGestureRecognizer) {
        
//        self.delegate?.cupViewTapped(self)
    }
}
