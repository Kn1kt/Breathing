//
//  TimeTableViewCell.swift
//  Breathing
//
//  Created by Nikitos on 13.10.2021.
//

import UIKit

final class TimeTableViewCell: UITableViewCell, ReusableCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    var cellModel: CellViewModelProtocol! {
        didSet { configure(on: cellModel) }
    }
    
    private func configure(on viewModel: CellViewModelProtocol) {
        let viewModel = viewModel as! TimeCellViewModelProtocol
        
        titleLabel.text = viewModel.timeInterval
        subtitleLabel.text = viewModel.duration
    }
}
