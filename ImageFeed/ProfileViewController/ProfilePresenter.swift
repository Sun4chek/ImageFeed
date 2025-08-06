//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Волошин Александр on 8/6/25.
//

protocol ProfilePresenterProtocol: AnyObject {
    var view : ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapExitBtn()
    
}


final class ProfilePresenter : ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    
    
    
    
    func viewDidLoad(){
        if let profile = profileService.profile{
            view?.updateUI(name: profile.name,
                           loginName: profile.loginName,
                           bio: profile.bio,
                           avatar:profileImageService.avatarImage)
        }
    }
    
    func didTapExitBtn(){
        view?.exitComfirm()
    }
}
