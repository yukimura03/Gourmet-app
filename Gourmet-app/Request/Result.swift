//
//  Result.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/10.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

enum Result<T,Error : Swift.Error> {
    case success(T)
    case failure(Error)
    
    init(value: T) {
        self = .success(value)
    }
    
    init (error: Error) {
        self = .failure(error)
    }
}
