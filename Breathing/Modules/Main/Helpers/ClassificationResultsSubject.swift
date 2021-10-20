//
//  ClassificationResultsSubject.swift
//  Breathing
//
//  Created by Nikitos on 10.10.2021.
//

import Foundation
import SoundAnalysis
import RxSwift
import RxRelay

final class ClassificationResultsListener: NSObject, SNResultsObserving {
    
    private let listener: PublishRelay<Event<SNClassificationResult>>
    
    init(_ listener: PublishRelay<Event<SNClassificationResult>>) {
        self.listener = listener
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        listener.accept(.error(error))
    }
    
    func requestDidComplete(_ request: SNRequest) {
        listener.accept(.completed)
    }
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        listener.accept(.next(result))
    }
}
