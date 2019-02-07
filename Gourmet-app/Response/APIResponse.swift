//
//  APIResponse.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/07.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

struct GnaviResponse<Restaurant: Decodable> : Decodable  {
    // このエリアの総店舗数
    let totalHitCount: Int
    
    // レストランデータ
    let restaurants: [Restaurant]
    
    enum CodingKeys : String, CodingKey {
        case totalHitCount = "total_hit_count"
        case restaurants
    }
}
