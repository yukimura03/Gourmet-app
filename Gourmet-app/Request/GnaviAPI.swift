//
//  GnaviAPI.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/07.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

final class GnaviAPI {
    struct SearchRestaurants : GnaviRequest {
        let keyid: String
        let hitPerPage: String
        let areacodeL: String
        let offsetPage: String
        
        // GnaviRequestが要求する連想型
        typealias Response = GnaviResponse<Restaurant>
        
        var method: HTTPMethod {
            return .get
        }
        
        var path: String {
            return "/RestSearchAPI/v3/"
        }
        
        var queryItems: [URLQueryItem] {
            return [URLQueryItem(name: "keyid", value: keyid)]
            
        }
    }
}
