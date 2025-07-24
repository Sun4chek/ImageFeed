import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("вызван вью дид лоуд сплэш контроллера")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupImageView()

        if oauth2TokenStorage.token != nil {

            switchToTabBarController()
            if let token = oauth2TokenStorage.token {
                fetchProfile(token)
            }
        } else {
            presentAuthViewController()
        }
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController по идентификатору")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupImageView() {
        let imageSplashScreenLogo = UIImage(named: "logo")

        imageView = UIImageView(image: imageSplashScreenLogo)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchProfile(_ token: String) {
        print("вызвана функция fetchProfile")
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token : token){ [weak self] result in
            UIBlockingProgressHUD.dismiss()
            

            print("мы здесь уже ")
            switch result {
                case .success(let profile):
                    print("\n\n\n\n\n\n\n\n\n\\n\n\n\n\n\nпопали в у спех в запросе профиля в сплэш дальше идет запрос картинки\n")
                    ProfileImageService.shared.fetchProfileImageURL(profile.loginName){ [weak self] result in
                        switch result {
                            case .success(let url):
                            print("Получили картинку !!!!!!!!!!!!!!!!!!!!!!!!!")
                        case .failure(let error):
                            print(error)
                        }
                    }
                    guard let self = self else { return }
                    self.switchToTabBarController()
                case .failure(let error):
                guard let self = self else { return }
                showErrorAlert(on: self, title: "Что-то пошло не так", message: "Не удалось загрузить профиль")
                    print(error)
            }
        }
    }
    
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
            vc.dismiss(animated: true)
           
        guard let token = oauth2TokenStorage.token else {
                return
            }
            
            fetchProfile(token)
        }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code : code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                showErrorAlert(on: self, title: "Что-то пошло не так", message: "Не удалось загрузить профиль")
            }
        }
    }
}

