//
//  GnaviAPIError.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/07.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

struct GnaviAPIError : Decodable, Error {
    let error: [ErrorMessage]
    
    struct ErrorMessage : Codable {
        let code: Int
        let message: String
    }
}

