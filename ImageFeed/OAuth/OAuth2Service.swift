//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Волошин Александр on 6/30/25.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private init() {}

    private var task: URLSessionTask?
    private var tokenStorage = OAuth2TokenStorage()
    
    
    func fetchOAuthToken(code : String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = makeOAuthTokenRequest(code: code)
        guard let request = request else {
            print("не получилось сформировать запрос")
            return
        }
        task = URLSession.shared.data(for: request){ [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenBody.self, from: data)
                    let token = response.accessToken
                    self?.tokenStorage.token = token
                    
                    completion(.success(token))
                }
                catch {
                    print("траблы с токеном не задекодился")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
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
    
    let tokenType = "bearer_token"
    
    var token : String? {
        get {
            UserDefaults.standard.string(forKey: tokenType)
        } set {
            UserDefaults.standard.set(newValue, forKey: tokenType)
            print("есть токен")
        }
    }
}
