//
//  SettingsManager.swift
//  Sinkr
//
//  Created by Jake Saferstein on 7/10/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation

class SettingsManager {
    
    static let sharedManager = SettingsManager()
    
    /** This prevents others from using initialiser */
    private init() {
        
    }
    
    func getAvailableSpecialMovies() -> [MoveType] {
        
        let placeholder = Index(row: -1, col: -1)
        
        return [.Bounce(placeholder, placeholder), .Electricity([])]
    }
}