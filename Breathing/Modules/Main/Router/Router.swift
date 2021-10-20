//
//  Router.swift
//  Breathing
//
//  Created by Nikitos on 10.10.2021.
//

import UIKit
import AVFoundation
import RxSwift

protocol RouterProtocol {
    var showActivityScreen: Binder<String> { get }
    
    func requestMicrophoneAccessIfNeeded() -> Single<Bool>
    func showNoMicrophoneAccessAlert()
}

final class Router: RouterProtocol {
    
    private weak var sourceController: UIViewController?
    
    init(sourceController: UIViewController) {
        self.sourceController = sourceController
    }
    
    var showActivityScreen: Binder<String> {
        return Binder(self) { router, breathinResults in
            let activityVC = UIActivityViewController(activityItems: [breathinResults], applicationActivities: nil)
            router.sourceController?.present(activityVC, animated: true)
        }
    }
    
    func requestMicrophoneAccessIfNeeded() -> Single<Bool> {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            return Single.create { publisher in
                Task {
                    let isAuthorized = await AVCaptureDevice.requestAccess(for: .audio)
                    publisher(.success(isAuthorized))
                }
                
                return Disposables.create()
            }
            
        case .denied, .restricted:
            return .just(false)
            
        case .authorized:
            return .just(true)
            
        @unknown default:
            fatalError("unknown authorization status for microphone access")
        }
    }
    
    func showNoMicrophoneAccessAlert() {
        let alertVC = UIAlertController(
            title: "No Microphone Access",
            message: "Please, allow microphone using in the settings",
            preferredStyle: .alert
        )
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        sourceController?.present(alertVC, animated: true)
    }
}
