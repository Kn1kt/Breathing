//
//  Breath.swift
//  Breathing
//
//  Created by Nikitos on 10.10.2021.
//

import Foundation

struct Breath: Hashable {
    
    enum BreathType: String {
        case inhale = "Inhale"
        case exhale = "Exhale"
    }
    
    let type: BreathType
    let time: DateInterval
}

// MARK: - Convenience init

extension Breath {
    
    init?(rawValue: String, time: DateInterval) {
        guard let type = BreathType(rawValue: rawValue) else {
            return nil
        }
        
        self.type = type
        self.time = time
    }
}
