//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Волошин Александр on 6/30/25.
//

import UIKit


protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
//MARK: Variebles
    let showWebViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?

    @IBOutlet var loginButton: UIButton!
    
    
//MARK: Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configButtFont()
        configureBackButton()
        
    }
    
////MARK: F/Users/alexvolo1998/Desktop/ImageFeed/ImageFeed/OAuthunctions
//    private func configButtFont(){
//        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
//    }
    
    private func configureBackButton() {

       navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
   navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        }
    }
}




extension AuthViewController: WebViewViewControllerDelegate {
    
    
    
    
    
    //MARK: доделать 
    
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        OAuth2Service.shared.fetchOAuthToken(code : code ){ [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("получилось авторизоваться")
                    vc.dismiss(animated: true)
                    guard let self = self else { return }
                    self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                case .failure(let error):
                    print("неполучилось авторизоваться \(error)")
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        
        vc.dismiss(animated: true)
    }
    
    
    
}
