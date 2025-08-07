//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Волошин Александр on 8/6/25.
//

import Foundation
import WebKit


protocol WebViewPresenterProtocol {
    var view : WebViewViewControllerProtocol? { get set }

    
    
    
    
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    
}

final class WebViewPresenter : WebViewPresenterProtocol {
    func code(from url: URL) -> String? {
        print("теперь тут   func code(from url: URL) -> String? ")
        return authHelper.code(from: url)
    }
    
    
    var authHelper : AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
            self.authHelper = authHelper
    }
    
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHiddenProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHiddenProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.001
    }
    
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        didUpdateProgressValue(0)
        view?.load(request: request)
    }
    
}

