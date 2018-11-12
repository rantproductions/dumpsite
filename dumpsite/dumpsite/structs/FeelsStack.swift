//
//  FeelsStack.swift
//  dumpsite
//
//  Created by Elisha Saylon on 11/12/18.
//  Copyright © 2018 Rant Productions. All rights reserved.
//

import Foundation

struct FeelsStack {
    fileprivate var array: [Feels] = []
    
    mutating func push(_ element: Feels) {
        array.append(element)
    }
    
    mutating func pop()-> Feels? {
        return array.popLast()
    }
    
    func peek()-> Feels? {
        return array.last
    }
    
    func count()-> Int {
        return array.count
    }
}
