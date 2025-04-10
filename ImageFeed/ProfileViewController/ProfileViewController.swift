import UIKit

final class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    imageGo()
    
    }
    
    func imageGo(){
        let profileImage = UIImage(named: "Photo")
        let imageView = UIImageView(image: profileImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant:70).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.font = .systemFont(ofSize: 23, weight: .semibold)
        
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        let shortNameLabel = UILabel()
        shortNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shortNameLabel)
        shortNameLabel.text = "@ekaterina_n"
        shortNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        shortNameLabel.textColor = UIColor(red: 174/255.0, green: 175/255.0, blue: 180/255.0, alpha: 1.0)
        shortNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        shortNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        
        
        let profileText = UILabel()
        profileText.text = "Hello world!"
        profileText.textColor = .white
        profileText.font = .systemFont(ofSize: 13, weight: .regular)
        profileText.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileText)
        profileText.topAnchor.constraint(equalTo: shortNameLabel.bottomAnchor, constant: 8).isActive = true
        profileText.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        
        
        
        let logOutButton = UIButton(type: .custom)
        if let customImage = UIImage(named: "Exit")?.withRenderingMode(.alwaysOriginal) {
            logOutButton.setImage(customImage, for: .normal)
        }
        logOutButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logOutButton)
        logOutButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        logOutButton.widthAnchor.constraint(equalToConstant:70).isActive = true
        logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logOutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    @objc
    private func didTapButton() {
    }
    
}

    
    

