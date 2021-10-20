//
//  UUIDIdentifable.swift
//  Breathing
//
//  Created by Nikitos on 13.10.2021.
//

import Foundation

protocol UUIDIdentifable {
    var identifier: UUID { get }
}

// MARK: - Hashable

extension UUIDIdentifable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
}
