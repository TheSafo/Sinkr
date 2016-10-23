//
//  BeerpongStructs.swift
//  Sinkr
//
//  Created by Jake Saferstein on 6/17/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation

//MARK: Data definition

enum ReRackType {
    //10
    case Default //Normal Rack
    
    //8
    case Marching // 2 straight lines of 4 ... idk why
    
    //7
    case Flower
    
    //6
    case Zipper //Meh
    case ThreeTwoOne
    case BigPlayButton
    case SixPack
    
    //5
    case Trapezoid
    case FlatTrapezoid //3-2-1 but no 1
    case House //2-2 square + 1 on top
    case ReverseHouse //House but upside down
    case ThumbsDown //line of 3 and 2 even
    case WizardStaff //1-2-1-1 ... idk
    
    //4
    case Square
    case Diamond
    case Rhombus
    case TwoOneOne //a penis... 2-1-1
    
    //3
    case ThinRedLine
    case PlayButton
    case TrafficLight
    case Triangle
    
    //2
    case Gents
    
    //1
    case OneCup
}

enum CupStatus: Character {
    case DNE  = "0"
    case Full = "*"
    case Hit  = "x"
}

struct Rack {
    
    /** The current type of the rack */
    var type: ReRackType
    
    /** The current cups status */
    var cups: [[CupStatus]]
    
    /** Whether or not this rack needs to be offset visually*/
    var isOffset: Bool
    
    /** A history of moves leading up to this rack */
    var listOfMoves: Stack<MoveType>
    
    /** Creates a new Rack, with no history */
    init(type: ReRackType, cups: [[CupStatus]], isOffset: Bool) {
        
        self.type = type
        self.cups = cups
        self.isOffset = isOffset
        
        self.listOfMoves = Stack<MoveType>()
        self.listOfMoves.push(.ReRack(type))
    }
    
    func copy() -> Rack {
        return Rack(type: type, cups: cups, isOffset: isOffset)
    }
    
    //TODO: Make sure these fail if not valid move
    mutating func hitCupAtIndex(ind: Index) {
        
        self.listOfMoves.push(.CupHit(ind))
        self.cups[ind.row][ind.col] = .Hit
    }
    
    mutating func reRackToType(type: ReRackType) {
        
        self.listOfMoves.push(.ReRack(type))
        
        let rack = rackForType(type)
        self.cups = rack.cups
        self.isOffset = rack.isOffset
        self.type = rack.type
    }
    
    nonmutating func numberOfCupsLeft() -> Int {
        
        var numLeft = 0
        self.cups.flatten().forEach { (cup) in
            switch cup {
                
            case .Full:
                numLeft += 1
                
            default:
                break
            }
        }
        return numLeft
    }
    
    nonmutating func validRacksForCurrentCups() -> [ReRackType] {
        
        return reRacksForNumberOfCups(self.numberOfCupsLeft())
    }
}

typealias Index = (row: Int, col: Int)

enum MoveType {
    
    //Default
    case CupHit(Index)
    case ReRack(ReRackType)
    
    /** Includes an array of all Indices hit */
    case Electricity([Index])
    
    /** The two indices removed */
    case Bounce(Index, Index)
}

//MARK: Useful Racks

let zero : [CupStatus]   = [.DNE, .DNE, .DNE, .DNE]
let one  : [CupStatus]   = [.DNE,.Full,.DNE]
let two  : [CupStatus]   = [.DNE,.Full,.Full,.DNE]
let three: [CupStatus]   = [.Full,.Full,.Full]
let four : [CupStatus]   = [.Full,.Full,.Full,.Full]

let DefaultRack = Rack(type: .Default, cups: [one, two, three, four], isOffset: false)

let MarchingRack = Rack(type: .Marching, cups: [two, two, two, two], isOffset: false)

let FlowerRack = Rack(type: .Marching, cups: [zero, two, three, two], isOffset: false)

let ZipperRack = Rack(type: .Zipper, cups: [zero, two, two, two], isOffset: true)
let ThreeTwoOneRack = Rack(type: .ThreeTwoOne, cups: [zero, one, two, three], isOffset: false)
let BigPlayButtonRack = Rack(type: .BigPlayButton, cups: [zero, [.DNE, .DNE,.Full,.DNE], [.Full, .Full, .Full,.DNE], two], isOffset: true)
let SixPackRack = Rack(type: .SixPack, cups: [zero, two, two, two], isOffset: false)

let TrapezoidRack = Rack(type: .Trapezoid, cups: [zero, [.DNE, .DNE,.Full,.DNE], two, two], isOffset: true)
let FlatTrapezoidRack = Rack(type: .FlatTrapezoid, cups: [zero, zero, two, three], isOffset: false)
let HouseRack = Rack(type: .House, cups: [zero, one, two, two], isOffset: false)
let ReverseHouseRack = Rack(type: .ReverseHouse, cups: [zero, two, two, one], isOffset: false)
let ThumbsDownRack = Rack(type: .ThumbsDown, cups: [zero, [.DNE,.DNE,.Full,.DNE], two, two],  isOffset: false)
let WizardStaffRack = Rack(type: .WizardStaff, cups: [one, one, two, one],  isOffset: false)

let SquareRack = Rack(type: .Square, cups: [zero, zero, two, two], isOffset: false)
let DiamondRack = Rack(type: .Diamond, cups: [zero, one, two, one], isOffset: false)
let RhombusRack =  Rack(type: .Rhombus, cups: [zero, zero, two, two], isOffset: true)
let TwoOneOneRack = Rack(type: .TwoOneOne, cups: [zero, one, one, two], isOffset: false)

let ThinRedLineRack = Rack(type: .ThinRedLine, cups: [zero, zero, zero, three], isOffset: false)
let PlayButtonRack = Rack(type: .PlayButton, cups: [zero, zero, [.DNE, .DNE,.Full,.DNE], two], isOffset: true)
let TrafficLightRack = Rack(type: .TrafficLight, cups: [zero, one, one, one], isOffset: false)
let TriangleRack = Rack(type: .Triangle, cups: [zero,zero,one,two], isOffset: false)

let GentsRack = Rack(type: .Gents, cups: [zero,zero,one,one], isOffset: false)

let OneCupRack = Rack(type: .OneCup, cups: [zero,zero,zero,one], isOffset: false)

//MARK: Rack Helper Methods
func rackForType(type: ReRackType) -> Rack {
    
    switch type {
    case .Default:
        return DefaultRack.copy()
    case .Marching:
        return MarchingRack.copy()
    case .Flower:
        return FlowerRack.copy()
    case .Zipper:
        return ZipperRack.copy()
    case .ThreeTwoOne:
        return ThreeTwoOneRack.copy()
    case .BigPlayButton:
        return BigPlayButtonRack.copy()
    case .SixPack:
        return SixPackRack.copy()
    case .Trapezoid:
        return TrapezoidRack.copy()
    case .FlatTrapezoid:
        return FlatTrapezoidRack.copy()
    case .House:
        return HouseRack.copy()
    case .ReverseHouse:
        return ReverseHouseRack.copy()
    case .ThumbsDown:
        return ThumbsDownRack.copy()
    case .WizardStaff:
        return WizardStaffRack.copy()
    case .Square:
        return SquareRack.copy()
    case .Diamond:
        return DiamondRack.copy()
    case .Rhombus:
        return RhombusRack.copy()
    case .TwoOneOne:
        return TwoOneOneRack.copy()
    case .ThinRedLine:
        return ThinRedLineRack.copy()
    case .PlayButton:
        return PlayButtonRack.copy()
    case .TrafficLight:
        return TrafficLightRack.copy()
    case .Triangle:
        return TriangleRack.copy()
    case .Gents:
        return GentsRack.copy()
    case .OneCup:
        return OneCupRack.copy()
    }
}

func reRacksForNumberOfCups(num: Int) -> [ReRackType] {
    
    switch num {
    case 1:
        return [.OneCup]
    case 2:
        return [.Gents]
    case 3:
        return [.ThinRedLine, .PlayButton, .TrafficLight, .Triangle]
    case 4:
        return [.Square, .Diamond, .Rhombus, .TwoOneOne]
    case 5:
        return [.Trapezoid, .FlatTrapezoid, .House, .ReverseHouse, .ThumbsDown, .WizardStaff]
    case 6:
        return [.Zipper, .ThreeTwoOne, .BigPlayButton, .SixPack]
    case 7:
        return [.Flower]
    case 8:
        return [.Marching]
    case 10:
        return [.Default]
    default:
        break
    }
    
    return []
}

//TODO: Let people put in nicknames or something later
func nameForType(type: ReRackType) -> String {
    
    switch type {
    case .Default:
        return "Game Start"
    case .Marching:
        return "Marching"
    case .Flower:
        return "Flower"
    case .Zipper:
        return "Zipper"
    case .ThreeTwoOne:
        return "3-2-1"
    case .BigPlayButton:
        return "Big Play Button"
    case .SixPack:
        return "6-Pack"
    case .Trapezoid:
        return "Trapezoid"
    case .FlatTrapezoid:
        return "Flat Trapezoid"
    case .House:
        return "House"
    case .ReverseHouse:
        return "Reverse House"
    case .ThumbsDown:
        return "Thumbs Down"
    case .WizardStaff:
        return "Wizard's Staff"
    case .Square:
        return "Square"
    case .Diamond:
        return "Diamond"
    case .Rhombus:
        return "Rhombus"
    case .TwoOneOne:
        return "2-1-1"
    case .ThinRedLine:
        return "Thin Red Line"
    case .PlayButton:
        return "Play Button"
    case .TrafficLight:
        return "Traffic Light"
    case .Triangle:
        return "Triangle"
    case .Gents:
        return "Gentlemen's"
    case .OneCup:
        return "One Cup"
    }
}