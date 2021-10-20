//
//  TimeCellViewModel.swift
//  Breathing
//
//  Created by Nikitos on 13.10.2021.
//

import Foundation

protocol TimeCellViewModelProtocol {
    var timeInterval: String { get }
    var duration: String { get }
}

final class TimeCellViewModel:
    Hashable,
    UUIDIdentifable,
    CellViewModelProtocol,
    TimeCellViewModelProtocol
{
    let identifier = UUID()
    let cellIdentifier = TimeTableViewCell.reuseIdentifier
    
    let timeInterval: String
    let duration: String
    
    let inhale: Breath
    let exhale: Breath
    
    init(inhale: Breath, exhale: Breath) {
        let timeInterval = DateInterval(
            start: inhale.time.start,
            end: max(inhale.time.start.advanced(by: 1), exhale.time.end)
        )
        
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        
        self.inhale = inhale
        self.exhale = exhale
        self.timeInterval = formatter.string(from: timeInterval.start, to: timeInterval.end)
        self.duration = "\(timeInterval.duration.rounded()) sec"
    }
}
