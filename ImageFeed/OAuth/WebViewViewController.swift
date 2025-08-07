//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Волошин Александр on 6/30/25.
//

import UIKit
import WebKit



protocol WebViewViewControllerProtocol:AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}


protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}



final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    @IBOutlet var webView: WKWebView!
    
    @IBOutlet var progressView: UIProgressView!
    private var estimatedProgressObservation: NSKeyValueObservation?
    weak var delegate: WebViewViewControllerDelegate?
    var presenter : WebViewPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.accessibilityIdentifier = "UnsplashWebView" 
        presenter?.viewDidLoad()
        webView.navigationDelegate = self
        progressView.progress = 0
        estimatedProgressObservation = webView.observe(
                    \.estimatedProgress,
                    options: [],
                    changeHandler: { [weak self] _, _ in
                        guard let self = self else { return }
                        presenter?.didUpdateProgressValue(webView.estimatedProgress)
                    })

    }


    
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    func load(request : URLRequest){
        webView.load(request)
    }
    
    
    
    
    
    
}





extension WebViewViewController: WKNavigationDelegate {
    
    
    //MARK: менять
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction)
        {
            delegate?.webViewViewController(self,didAuthenticateWithCode : code)
            decisionHandler(.cancel)
   print(code)
        } else {
            decisionHandler(.allow) //4
        }
    }
        
    
    //
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url{
            print("были в функции code(from navigationAction: WKNavigationAction)")
            return presenter?.code(from: url)
            //6
        } else {
            return nil
        }
    }
}
