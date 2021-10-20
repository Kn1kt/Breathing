//
//  HeaderCellViewModel.swift
//  Breathing
//
//  Created by Nikitos on 14.10.2021.
//

import Foundation
import UIKit.UIColor
import RxSwift
import RxRelay

struct HeaderCellViewModelBindings {
    let buttonTapped: Observable<Void>
}

protocol HeaderCellViewModelProtocol {
    var state: Observable<HeaderCellViewModel.State> { get }
    
    func setup(bindings: HeaderCellViewModelBindings) -> Disposable
}

final class HeaderCellViewModel:
    Hashable,
    UUIDIdentifable,
    CellViewModelProtocol,
    HeaderCellViewModelProtocol
{
    struct State: Hashable {
        let title: String
        let titleColor: UIColor
        let subtitle: String
        let duration: String?
    }
    
    let identifier = UUID()
    let cellIdentifier = HeaderTableViewCell.reuseIdentifier
    
    var state: Observable<State> {
        return Observable.combineLatest(
            currentBreath.throttle(.milliseconds(500), scheduler: MainScheduler.instance),
            isBreathing)
            .compactMap { [weak self] in self?.makeState(from: $0, isBreathing: $1) }
    }
    
    let isBreathing = BehaviorRelay<Bool>(value: false)
    
    
    var buttonTapped: Observable<Void> { _buttonTapped.asObservable() }
    private let _buttonTapped = PublishRelay<Void>()
    
    private let currentBreath: Observable<Breath?>
    
    private let dateComponentsFormatter = DateComponentsFormatter()
    
    init(currentBreath: Observable<Breath?>) {
        self.currentBreath = currentBreath
    }
    
    // MARK: - Bindings
    
    func setup(bindings: HeaderCellViewModelBindings) -> Disposable {
        return Disposables.create([
            bindings.buttonTapped.bind(to: _buttonTapped)
        ])
    }
    
    // MARK: - State
    
    private func makeState(from breath: Breath?, isBreathing: Bool) -> State {
        guard isBreathing else {
            return .init(
                title: "Start",
                titleColor: .systemGreen,
                subtitle: "Press Start to Begin Training",
                duration: nil
            )
        }
        
        guard let breath = breath else {
            return .init(
                title: "Stop",
                titleColor: .systemRed,
                subtitle: "Calm",
                duration: nil
            )
        }

        let subtitle: String
        
        switch breath.type {
        case .inhale:
            subtitle = "Inhale"
        case .exhale:
            subtitle = "Exhale"
        }
        
        return .init(
            title: "Stop",
            titleColor: .systemRed,
            subtitle: subtitle,
            duration: dateComponentsFormatter.string(from: breath.time.duration)
        )
    }
}
