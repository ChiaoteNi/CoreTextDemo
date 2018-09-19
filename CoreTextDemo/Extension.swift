//
//  Extension.swift
//  CoreTextDemo
//
//  Created by Chiao-Te Ni on 2018/9/16.
//  Copyright © 2018年 aaron. All rights reserved.
//

import Foundation

extension CFRange {
    static var zero: CFRange { return CFRange(location: 0, length: 0) }
}

extension Array {
    
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < self.count else { return nil }
        let element = self[index]
        return element
    }
}
