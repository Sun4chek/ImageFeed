//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Волошин Александр on 7/24/25.
//

import UIKit
 
final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        // Configure ImagesListViewController with presenter BEFORE setting viewControllers
        if let imagesListVC = imagesListViewController as? ImagesListViewController {
            let imagesListPresenter = ImagesListPresenter()
            imagesListVC.configure(imagesListPresenter)
        }
        
        self.viewControllers = [imagesListViewController, profileViewController]
       
        let profilePresenter = ProfilePresenter()
        profileViewController.configure(profilePresenter)
        profilePresenter.view = profileViewController
    }
}
