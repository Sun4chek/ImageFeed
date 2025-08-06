//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Волошин Александр on 7/15/25.
//

import Foundation
import Kingfisher
import UIKit

private struct UserResult: Codable {
    enum CodingKeys : String, CodingKey {
        case profileImage = "profile_image"
    }
    
    var profileImage: ProfileImage
    
    
}

private struct ProfileImage: Codable {
    var small : String?
    var medium: String?
    var large: String?
}

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private init() {}
    private let storage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var avatarURL: String?
    var avatarImage = UIImage()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
        
    
    
    func fetchProfileImageURL(_ username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        
        if let _ = task {
            print("[ProfileImageService] request is already in progress")
            completion(.failure(ProfileError.invalidRequest))
            return
        }
        
        guard
            let token = storage.token,
            let request = makerequestFoAvatarURL(username: username,token: token) else {
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }

        task = URLSession.shared.objectTask(for: request, completion: { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let url = response.profileImage.small else { return }
                self.updateAvatar(url: url)
                print("\navatar image was save\n")
                completion(.success(url))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": url])
                Task { @MainActor in
                    self.profileImage()}

                
            case .failure(let error):
                print("can't fetch avatar")
                completion(.failure(error))
            }
            
        })
        task?.resume()
    }
    
    @MainActor  func profileImage(){
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        

            let processor = RoundCornerImageProcessor(cornerRadius: 25)
            let rect = CGRect(x: 0, y: 0, width: 350, height: 400)
            let imageView = UIImageView(frame: rect)
            imageView.clipsToBounds = true
            guard let avatarURL = avatarURL, let imageUrl = URL(string: avatarURL) else { return }
            KingfisherManager.shared.cache.clearMemoryCache()
            KingfisherManager.shared.cache.clearDiskCache()
            imageView.kf.setImage(with: imageUrl,
                                  placeholder: placeholderImage,
                                  options: [.processor(processor)]) { result in
                switch result {
                case .success(let value):
                    self.avatarImage = value.image
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                    
                case .failure(let error):
                    print(error)
                    
                }
            }
        }
    
    
    func makerequestFoAvatarURL(username : String, token: String) -> URLRequest?{
        
        guard let baseUrl = Constants.defaultBaseURL else { return nil }
        let url = URL(
            string: "/users/\(username)",
            relativeTo: baseUrl)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func updateAvatar(url: String){
        self.avatarURL = url
    }
    
    func reset() {
        avatarURL = nil
        task?.cancel()
        task = nil
    }
}
