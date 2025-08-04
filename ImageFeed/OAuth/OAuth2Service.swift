//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Волошин Александр on 6/30/25.
//


import Foundation
import SwiftKeychainWrapper



enum OAuth2Error: Error {
    case invalidRequest
}


final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private init() {}

    private var task: URLSessionTask?
    private var lastCode :String?
    private var tokenStorage = OAuth2TokenStorage()
    
    
    func fetchOAuthToken(code : String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
            if task != nil {
                if lastCode != code {
                    task?.cancel()
                } else {
                    completion(.failure(OAuth2Error.invalidRequest))
                    return
                }
            } else {
                if lastCode == code {
                    completion(.failure(OAuth2Error.invalidRequest))
                    return
                }
            }
        
        lastCode = code
        
        let request = makeOAuthTokenRequest(code: code)
        guard let request = request else {
            completion(.failure(OAuth2Error.invalidRequest))
            print("не получилось сформировать запрос на авторизацию")
            return
        }
        
        print("запрос для 1 реги готов и передан в таск ")
        task = URLSession.shared.objectTask(for: request, completion: { [weak self] (result: Result<OAuthTokenBody, Error>) in
            switch result {
            case .success(let response):
                let token = response.accessToken
                self?.tokenStorage.token = token
                completion(.success(token))
            case .failure(let error):
                print("[OAuth2Service] failed to make a request: \(error)")
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastCode = nil
        })
        task?.resume()
    }
        

    
    private func makeOAuthTokenRequest(code: String?) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com")else {
            return nil
        }
        var request = URLRequest(url: baseURL)
        if let code = code {
            let url = URL(
                string: "/oauth/token"
                + "?client_id=\(Constants.accessKey)"
                + "&&client_secret=\(Constants.secretKey)"
                + "&&redirect_uri=\(Constants.redirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                relativeTo: baseURL
            )!
            request.httpMethod = "POST"
            request = URLRequest(url: url)
        }
         return request
     }
}



class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    let tokenType = "bearer_token"
    private let tokenKey = "token"
    
    var token : String? {
        get {
            print("взяли токен из кей чейн")
            return KeychainWrapper.standard.string(forKey: tokenKey)
        } set {
            if let token = newValue {
                // Сохраняем токен в Keychain
                KeychainWrapper.standard.set(token, forKey: tokenKey)
                print("токен сохранен в кей чейн")
            } else {
                // Удаляем токен из Keychain
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
