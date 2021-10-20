//
//  ViewModelSection.swift
//  Breathing
//
//  Created by Nikitos on 14.10.2021.
//

import Foundation
import RxSwift

struct ViewModelSection {
    
    let header: HeaderCellViewModel
    
    private(set) var breathingTimes = [TimeCellViewModel]()
    
    init(currentBreath: Observable<Breath?>) {
        header = HeaderCellViewModel(currentBreath: currentBreath)
    }
    
    // MARK: - Updates
    
    mutating func add(inhale: Breath, exhale: Breath) {
        let breathingTime = TimeCellViewModel(inhale: inhale, exhale: exhale)
        breathingTimes.insert(breathingTime, at: 0)
    }
    
    mutating func setClassifying(_ isClassifying: Bool) {
        if isClassifying {
            breathingTimes = []
        }
        
        header.isBreathing.accept(isClassifying)
    }
    
    // MARK: - Visible Sections
    
    func makeVisibleSections() -> [ViewModelVisibleSection] {
        let headerSection = ViewModelVisibleSection(
            identifier: 0,
            title: nil,
            items: [.init(cellModel: header)]
        )
        
        let resultsSection = ViewModelVisibleSection(
            identifier: 1,
            title: "Results",
            items: breathingTimes.map(ViewModelItem.init)
        )
        
        return breathingTimes.isEmpty ? [headerSection] : [headerSection, resultsSection]
    }
}
