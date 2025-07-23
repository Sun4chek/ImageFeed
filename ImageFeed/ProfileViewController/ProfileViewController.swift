import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ypBlack")
        setupUI()
        nameLabel.text = profileService.profile?.name ?? "Екатерина Новикова"
        shortNameLabel.text = profileService.profile?.loginName
        profileText.text = profileService.profile?.bio
        profileImageServiceObserver = NotificationCenter.default    // 2
            .addObserver(
                forName: ProfileImageService.didChangeNotification, // 3
                object: nil,                                        // 4
                queue: .main                                        // 5
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()                                 // 6
            }
        updateAvatar()
    }
    
    private func updateAvatar() {                                   // 8
            guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
            else { return }
        print("imageUrl: \(url)")

        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))

        let processor = RoundCornerImageProcessor(cornerRadius: 35) // Радиус для круга
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale), // Учитываем масштаб экрана
                .cacheOriginalImage, // Кэшируем оригинал
                .forceRefresh // Игнорируем кэш, чтобы обновить
            ]) { result in

                switch result {
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                case .failure(let error):
                    print(error)
                }
            }
        }
    
    private lazy var avatarImageView: UIImageView = {
        let avatarImage = UIImage(resource: .photo)
        let imageView = UIImageView()
        imageView.image = avatarImage
        imageView.layer.cornerRadius = 70.0 / 2
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel : UILabel! = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 23, weight: .semibold)
        return nameLabel
    }()
        
    private lazy var shortNameLabel : UILabel! = {
        let shortNameLabel = UILabel()
        shortNameLabel.translatesAutoresizingMaskIntoConstraints = false
        shortNameLabel.text = "@ekaterina_n"
        shortNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        shortNameLabel.textColor = UIColor(red: 174/255.0, green: 175/255.0, blue: 180/255.0, alpha: 1.0)
        return shortNameLabel
    }()
    
    private lazy var profileText : UILabel! = {
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
    private func didTapButton() {
    }
    
}

    
    

