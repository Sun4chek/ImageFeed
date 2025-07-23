//
//  structuraForToken.swift
//  ImageFeed
//
//  Created by Волошин Александр on 6/30/25.
//

import Foundation

struct OAuthTokenBody: Decodable {
    let accessToken: String
    let tokenType: String?
    let scope: String?
    let createdAt: Int?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
