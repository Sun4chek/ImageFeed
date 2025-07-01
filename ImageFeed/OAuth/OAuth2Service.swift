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
    
    
    func makeOAuthTokenRequest(code: String?) -> URLRequest? {
        
        let baseURL = URL(string: "https://unsplash.com")!
        var request = URLRequest(url: baseURL)
        if let code = code {
            let url = URL(
                string: "/oauth/token"
                + "?client_id=\(Constants.accessKey)"         // Используем знак ?, чтобы начать перечисление параметров запроса
                + "&&client_secret=\(Constants.secretKey)"    // Используем &&, чтобы добавить дополнительные параметры
                + "&&redirect_uri=\(Constants.redirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                relativeTo: baseURL                           // Опираемся на основной или базовый URL, которые содержат схему и имя хоста
            )!
            request.httpMethod = "POST"
            request = URLRequest(url: url)
        }
         return request
     }
    
    
    
    
    //MARK: ДОПИСАТЬ
    // это вызывается контролерром и тут делается декодирование и сохранение
    func fetchOAuthToken(code : String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = makeOAuthTokenRequest(code: code)
        guard let request = request else {
            print("gbplf ssefsefsefsefsefsefsfsefsefsefsef")
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
                    print("траблы с токеном не задекоился")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
                
            }
            
        }
        task?.resume()
    }
    
}











//MARK: СДЕЛАТЬ СОХРАНЕНИЕ В ЮЗЕР ДЕФОЛТС

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
