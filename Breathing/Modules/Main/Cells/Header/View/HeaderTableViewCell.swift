//
//  HeaderTableViewCell.swift
//  Breathing
//
//  Created by Nikitos on 14.10.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class HeaderTableViewCell: UITableViewCell, ReusableCell {
    
    // MARK: Labels
    
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    
    // MARK: Buttons
    
    @IBOutlet private weak var startButton: UIButton!
    
    // MARK: Stack
    
    @IBOutlet private weak var stackView: UIStackView!
    
    var cellModel: CellViewModelProtocol! {
        didSet { configure(on: cellModel) }
    }
    
    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        startButton.titleLabel?.adjustsFontForContentSizeCategory = true
        durationLabel.font = UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .monospacedDigitSystemFont(ofSize: 15, weight: .regular))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        startButton.layer.cornerRadius = startButton.frame.width / 2
    }
    
    private func configure(on viewModel: CellViewModelProtocol) {
        let viewModel = viewModel as! HeaderCellViewModelProtocol
        
        let bindings = HeaderCellViewModelBindings(
            buttonTapped: startButton.rx.tap.asObservable()
        )
        
        disposeBag.insert(
            viewModel.state
                .distinctUntilChanged()
                .bind(to: updateUI),
            
            viewModel.setup(bindings: bindings)
        )
    }
}

// MARK: - Bindings

extension HeaderTableViewCell {
    
    private var updateUI: Binder<HeaderCellViewModel.State> {
        return Binder(self) { cell, state in
            cell.startButton.setTitle(state.title, for: .normal)
            cell.startButton.tintColor = state.titleColor
            cell.subtitleLabel.text = state.subtitle
            cell.durationLabel.text = state.duration
            cell.durationLabel.isHidden = state.duration == nil
            
            if cell.window != nil {
                UIView.animate(
                    withDuration: 0.3,
                    animations: { cell.stackView.layoutIfNeeded() }
                )
            }
        }
    }
}
