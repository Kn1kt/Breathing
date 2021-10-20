//
//  ViewModel.swift
//  Breathing
//
//  Created by Nikitos on 10.10.2021.
//

import Foundation
import SoundAnalysis
import RxSwift
import RxRelay

protocol ViewModelProtocol {
    var sections: Observable<[ViewModelVisibleSection]> { get }
    var isShareEnabled: Observable<Bool> { get }
    
    func setup(bindings: ViewModelBindings) -> Disposable
}

final class ViewModel: ViewModelProtocol {
    
    var sections: Observable<[ViewModelVisibleSection]> { section.map { $0.makeVisibleSections() } }
    var isShareEnabled: Observable<Bool> { section.map { !$0.breathingTimes.isEmpty } }
    
    private let section: BehaviorRelay<ViewModelSection>
    
    private let router: RouterProtocol
    private let audioClassifier: AudioClassifier
    
    private let currentBreath = BehaviorRelay<Breath?>(value: nil)
    
    init(router: RouterProtocol, audioClassifier: AudioClassifier) {
        self.router = router
        self.audioClassifier = audioClassifier
        self.section = BehaviorRelay(value: .init(currentBreath: currentBreath.asObservable()))
    }
    
    // MARK: - Bindings
    
    func setup(bindings: ViewModelBindings) -> Disposable {
        let router = self.router
        let audioClassifier = self.audioClassifier
        
        var disposables = [Disposable]()
        
        let stateChanged = Observable.merge(
            bindings.share.map { false },
            section
                .flatMapLatest { section in
                    return section.header.buttonTapped
                        .withLatestFrom(section.header.isBreathing)
                        .map { !$0 }
                }
                .share()
        )
        
        let startSoundClassification = stateChanged
            .filter { $0 }
            .flatMapLatest { _ in
                return router.requestMicrophoneAccessIfNeeded()
                    .catchAndReturn(false)
                    .observe(on: MainScheduler.instance)
                    .do(onSuccess: { isAccessGranted in
                        guard !isAccessGranted else { return }
                        router.showNoMicrophoneAccessAlert()
                    })
                        }
            .filter { $0 }
            .share()
        
        let stopSoundClassification = stateChanged.filter { !$0 }
        
        let newBreath = startSoundClassification
            .flatMapLatest { _ in audioClassifier.startSoundClassification().materialize() }
            .compactMap(\.element)
            .observe(on: MainScheduler.instance)
            .withLatestFrom(currentBreath) { ($0, $1) }
            .map { recognizedBreath, currentBreath -> Breath? in
                guard let recognizedBreath = recognizedBreath else {
                    return nil
                }
                
                guard let currentBreath = currentBreath,
                      recognizedBreath.type == currentBreath.type else {
                          return recognizedBreath
                      }
                
                return Breath(
                    type: currentBreath.type,
                    time: DateInterval(
                        start: currentBreath.time.start,
                        duration: recognizedBreath.time.end.timeIntervalSince(currentBreath.time.start)
                    )
                )
            }
            .share()
        
        disposables.append(
            newBreath.bind(to: currentBreath)
        )
        
        disposables.append(
            Observable
                .combineLatest(
                    newBreath
                        .filter { $0?.type == .inhale },
                    newBreath
                        .filter { $0?.type == .exhale }
                )
                .sample(newBreath.filter { $0?.type == .inhale || $0 == nil })
                .compactMap { inhale, exhale -> (Breath, Breath)? in
                    guard let inhale = inhale,
                          let exhale = exhale else {
                              return nil
                          }
                    
                    return (inhale, exhale)
                }
                .filter { inhale, exhale in inhale.time < exhale.time }
                .withLatestFrom(section) { ($0, $1) }
                .map { breath, section in
                    var section = section
                    section.add(inhale: breath.0, exhale: breath.1)
                    return section
                }
                .bind(to: section)
        )
        
        disposables.append(
            Observable.merge(startSoundClassification, stopSoundClassification)
                .withLatestFrom(section) { ($0, $1) }
                .map { isClassifying, section in
                    var section = section
                    section.setClassifying(isClassifying)
                    return section
                }
                .bind(to: section)
        )
        
        disposables.append(
            stopSoundClassification
                .withUnretained(self)
                .subscribe { vm, _ in
                    vm.audioClassifier.stopSoundClassification()
                    vm.currentBreath.accept(nil)
                }
        )
        
        disposables.append(
            bindings.share
                .withLatestFrom(section)
                .map { section in
                    return "Results:\n" + section.breathingTimes
                        .map { cellModel in
                            return "inhale-exhale: " + cellModel.timeInterval
                            + ", duration: " + cellModel.duration
                        }
                        .joined(separator: "\n")
                }
                .bind(to: router.showActivityScreen)
        )
        
        return Disposables.create(disposables)
    }
}
