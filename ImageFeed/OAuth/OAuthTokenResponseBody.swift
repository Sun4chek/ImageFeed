//
//  structuraForToken.swift
//  ImageFeed
//
//  Created by Волошин Александр on 6/30/25.
//

import Foundation

struct OAuthTokenBody: Decodable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
    
    var accessToken: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
    }
}
