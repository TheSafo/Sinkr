//
//  UsefulHelpers.swift
//  Sinkr
//
//  Created by Jake Saferstein on 7/9/16.
//  Copyright © 2016 Jake Saferstein. All rights reserved.
//

import Foundation

//MARK: Stack Definition

protocol Container {
    associatedtype ItemType
    mutating func append(item: ItemType)
    var count: Int { get }
    subscript(i: Int) -> ItemType { get }
}

struct Stack<Element>: Container {
    // original Stack<Element> implementation
    var items = [Element]()
    mutating func push(item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
    // conformance to the Container protocol
    mutating func append(item: Element) {
        self.push(item)
    }
    func peek() -> Element {
        return items.last!
    }
    var count: Int {
        return items.count
    }
    subscript(i: Int) -> Element {
        return items[i]
    }
}