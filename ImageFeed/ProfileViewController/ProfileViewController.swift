import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter : ProfilePresenterProtocol? { get }
    
    func updateUI(name: String ,loginName: String, bio: String, avatar : UIImage?)
    func exitComfirm()
}


final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {

    private var profileImageServiceObserver: NSObjectProtocol?
    var presenter : ProfilePresenterProtocol?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        view.backgroundColor = UIColor(named: "ypBlack")
        setupUI()
        
        
        

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    func updateUI(name: String ,loginName: String, bio: String, avatar : UIImage?){
        nameLabel.text = name
        shortNameLabel.text = "@\(loginName)"
        profileText.text = bio
        avatarImageView.image = avatar
    }
    
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
    }
    
    
    private func updateAvatar() {                                   // 8
            guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
            else { return }
        print("imageUrl: \(url)")

        
        }
    
    lazy var avatarImageView: UIImageView = {
        let avatarImage = UIImage(resource: .photo)
        let imageView = UIImageView()
        imageView.image = avatarImage
        imageView.layer.cornerRadius = 70.0 / 2
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var nameLabel : UILabel! = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 23, weight: .semibold)
        return nameLabel
    }()
        
    lazy var shortNameLabel : UILabel! = {
        let shortNameLabel = UILabel()
        shortNameLabel.translatesAutoresizingMaskIntoConstraints = false
        shortNameLabel.text = "@ekaterina_n"
        shortNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        shortNameLabel.textColor = UIColor(red: 174/255.0, green: 175/255.0, blue: 180/255.0, alpha: 1.0)
        return shortNameLabel
    }()
    
    lazy var profileText : UILabel! = {
        let profileText = UILabel()
        profileText.text = "Hello world!"
        profileText.textColor = .white
        profileText.font = .systemFont(ofSize: 13, weight: .regular)
        profileText.translatesAutoresizingMaskIntoConstraints = false
        return profileText
    }()
    
    private lazy var logOutButton : UIButton! = {
        let logOutButton = UIButton(type: .custom)
        if let customImage = UIImage(named: "Exit")?.withRenderingMode(.alwaysOriginal) {
            logOutButton.setImage(customImage, for: .normal)
        }
        logOutButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        return logOutButton
    }()
    
    private func setupUI() {
        view.addSubview(avatarImageView)
        view.addSubview(profileText)
        view.addSubview(nameLabel)
        view.addSubview(logOutButton)
        view.addSubview(shortNameLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant:70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileText.topAnchor.constraint(equalTo: shortNameLabel.bottomAnchor, constant: 8),
            profileText.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            shortNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            shortNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            logOutButton.heightAnchor.constraint(equalToConstant: 70),
            logOutButton.widthAnchor.constraint(equalToConstant:70),
            logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logOutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        
        ])
    }
    @objc
    func didTapButton() {
            self.presenter?.didTapExitBtn()
    }
    
    func exitComfirm(){
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "Да", style: .default) { _ in
        let profileLogoutService = ProfileLogoutService.shared
        profileLogoutService.logout()
            
        }
        
        let cancelBtn = UIAlertAction(title: "Нет", style: .cancel)
        alert.addAction(cancelBtn)
        alert.addAction(okBtn)
 
        
        present(alert, animated: true)
    }
    
}

    
    

