//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Волошин Александр on 8/6/25.
//

import Foundation

protocol AuthHelperProtocol{
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration : AuthConfiguration
    
    init(configauration: AuthConfiguration = .standard){
        self.configuration = configauration
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else {
            return nil
        }
        
        return URLRequest(url: url)
    }
    
    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else { return nil}
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return nil}
        
        return url
    }
    
    func code(from url: URL) -> String? {
        if
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value                                           
        } else {
            return nil
        }
    }
    
    
}
