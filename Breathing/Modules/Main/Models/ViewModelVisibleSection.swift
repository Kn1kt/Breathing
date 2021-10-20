//
//  ViewModelVisibleSection.swift
//  Breathing
//
//  Created by Nikitos on 14.10.2021.
//

import Foundation

struct ViewModelVisibleSection: DiffableSection {
    let identifier: Int
    let title: String?
    let items: [ViewModelItem]
}

// MARK: - Hashable

extension ViewModelVisibleSection: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
