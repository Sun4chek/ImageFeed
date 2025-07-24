//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Волошин Александр on 7/14/25.
//

import Foundation

enum ProfileError:Error{
    case networkError
    case invalidRequest
}

struct Profile {
    var name : String
    var loginName : String
    var bio : String?
}

struct ProfileResult: Codable{
    var username : String
    var first_name : String
    var last_name : String?
    var bio : String?
}

final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        if let _ = task {
            print("запрос уже отправлен")
            completion(.failure(ProfileError.invalidRequest))
            return
        }
        
        let request = makePofileRequest(token: token)
        guard let request = request else {
            print("не получилось сформировать запрос")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        task = URLSession.shared.objectTask(for: request, completion: { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let profile = Profile(name: "\(response.first_name) \(response.last_name ?? "")", loginName:"\(response.username)", bio: response.bio ?? "")
                print("профиль без фотки получен")
                self.updateProfile(profile: profile)
                completion(.success(profile))
                
            case .failure(let error):
                print("не получилось задекодить профиль")
                completion(.failure(error))
            }
        })
        task?.resume()
    }
    
    func updateProfile(profile: Profile) {
        self.profile = profile
        print("профиль без картинки сохранен")
    }
    
    private func makePofileRequest(token: String) -> URLRequest? {
        
        guard let baseUrl = Constants.defaultBaseURL else { return nil }
        let url = URL(
            string: "/me",
            relativeTo: baseUrl)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
