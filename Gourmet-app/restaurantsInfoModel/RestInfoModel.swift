//
//  GetApiModel.swift
//  Gourmet-app
//
//  Created by minagi on 2019/01/20.
//  Copyright © 2019 minagi. All rights reserved.
//

import UIKit

class RestInfoModel {
    /// レストラン情報から必要な項目だけを抜き出す箱です
    struct apiData: Codable {
        let total_hit_count: Int
        let rest: [restaurantsData]
    }
    struct restaurantsData: Codable {
        let name: String
        let address: String
        let tel: String
        let budget: Int
        let access: Access
        let imageUrl: image
        
        private enum CodingKeys: String, CodingKey {
            case name
            case address
            case tel
            case budget
            case access
            case imageUrl = "image_url"
        }
        
        struct Access: Codable {
            let station: String
            let walk: String
        }
        
        struct image: Codable {
            let shopImage: String
            
            private enum CodingKeys: String, CodingKey {
                case shopImage = "shop_image1"
            }
        }
    }
}
