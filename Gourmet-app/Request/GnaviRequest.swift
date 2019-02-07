//
//  GnaviRequest.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/07.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

protocol GnaviRequest {
    associatedtype Response: Decodable
    
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}

extension GnaviRequest {
    var baseURL: URL {
        return URL(string: "https://api.gnavi.co.jp")!
    }
}
