//
//  RackView.swift
//  
//
//  Created by Jake Saferstein on 6/18/16.
//
//

import Foundation
import UIKit
import SnapKit

let cupPadding: CGFloat = 5

class RackView : UIView {
    
    static var rackWidth: CGFloat {
        get {
            let scrWidth = UIScreen.mainScreen().bounds.width
            return scrWidth * 0.6
        }
    }
    
    var cupViews: Array<Array<CupView>> = [[], [], [], []]
    
    var rack :Rack
    
    //MARK: Initialization
    init(rack: Rack) {
        self.rack = rack
        super.init(frame: CGRectZero)
        
        self.updateRack()
    }
    
    convenience init() {
        self.init(rack: DefaultRack.copy())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Prviate updating Rack Visuals
    
    private func resetRack() {
        
        self.subviews.forEach({$0.removeFromSuperview()})
        self.cupViews = [[], [], [], []]
    }
    
    private func updateRack() {
        
        //Populate the CupViews
        var rowInd = 0
        for row in rack.cups {
            
            var colInd = 0
            
            for col in row {
                
                let cupVw = CupView(index: (rowInd, colInd), status: col)
                cupVw.delegate = self
                
                self.addSubview(cupVw)

                cupVw.snp_makeConstraints(closure: { (make) in
                    make.width.height.equalTo(CupView.cupWidthHeight)
                })
                
                cupViews[rowInd].append(cupVw)
                colInd += 1
            }
            rowInd += 1
        }
        
        self.updateConstraintsForCurrentRack()
    }
    
    private func updateConstraintsForCurrentRack() {
        
        //Layout Cups
        var topConstraint = self.snp_top
        var offSetTopConstraint: ConstraintItem? = nil
        
        //Add all constraints
        var rowInd = 0
        for row in rack.cups {
            
            if row.count == 3 {
                
                let leftCup = cupViews[rowInd][0]
                let centerCup = cupViews[rowInd][1]
                let rightCup = cupViews[rowInd][2]
                
                centerCup.snp_makeConstraints(closure: { (make) in
                    make.width.height.equalTo(CupView.cupWidthHeight)
                    if rowInd == 0 {
                        make.top.equalTo(topConstraint)
                    }
                    else {
                        make.top.equalTo(topConstraint).offset(cupPadding)
                    }
                    make.centerX.equalTo(self)
                })
                leftCup.snp_makeConstraints(closure: { (make) in
                    make.width.height.equalTo(CupView.cupWidthHeight)
                    make.right.equalTo(centerCup.snp_left).offset(-cupPadding)
                    make.centerY.equalTo(centerCup)
                })
                rightCup.snp_makeConstraints(closure: { (make) in
                    make.width.height.equalTo(CupView.cupWidthHeight)
                    make.left.equalTo(centerCup.snp_right).offset(cupPadding)
                    make.centerY.equalTo(centerCup)
                })
                
                topConstraint = centerCup.snp_bottom
            }
            else {
                
                var leftConst = self.snp_left
                var colInd = 0
                for cupVw in cupViews[rowInd] {
                    
                    cupVw.snp_makeConstraints(closure: { (make) in
                        make.height.width.equalTo(CupView.cupWidthHeight)
                        
                        if colInd == 0 {
                            make.left.equalTo(leftConst)
                        }
                        else {
                            make.left.equalTo(leftConst).offset(cupPadding)
                        }
                        
                        if rack.isOffset && colInd % 2 == 1 {
                            if offSetTopConstraint == nil {
                                make.bottom.equalTo(cupViews[rowInd][0].snp_centerY)
                            }
                            else {
                                make.top.equalTo(offSetTopConstraint!).offset(cupPadding)
                            }
                        }
                        else {
                            if rowInd == 0 {
                                make.top.equalTo(topConstraint)
                            }
                            else {
                                make.top.equalTo(topConstraint).offset(cupPadding)
                            }
                        }
                        
                        leftConst = cupVw.snp_right
                    })
                    
                    colInd += 1
                }
                topConstraint = cupViews[rowInd][0].snp_bottom
                offSetTopConstraint = cupViews[rowInd][1].snp_bottom
            }
            rowInd += 1
        }
    }
    
    //MARK: Public methods to update view
    
    func makeTopRack() {
        
        self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
    }
    
    func reRackToType(type: ReRackType) {
        
        self.rack.reRackToType(type)
        
        
        self.resetRack()
        self.updateRack()
    }
}

extension RackView : CupViewDelegate {
    
    func cupViewTapped(cupVw: CupView) {
        
        switch cupVw.status {
        case .Full:
            let ind = cupVw.index
            
            cupVw.status = .Hit
            self.rack.hitCupAtIndex(ind)

        default:
            break
        }
    }
}