//
//  Reusable.swift
//  Breathing
//
//  Created by Nikitos on 13.10.2021.
//

import Foundation

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    
    static var reuseIdentifier: String { String(describing: self) }
    
}
