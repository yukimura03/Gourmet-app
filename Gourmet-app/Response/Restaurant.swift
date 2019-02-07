//
//  Restaurants.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/07.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

struct Restaurant : Decodable {
    /// 店舗名
    let name: String
    
    /// 住所
    let address: String
    
    /// 電話番号
    let tel: String
    
    /// 予算金額
    let budget: Int
    
    /// 最寄駅と駅からの所要時間
    let access: Access
    
    /// 店舗のサムネ画像
    let imageUrl: Image
    
    private enum CodingKeys : String, CodingKey {
        case name
        case address
        case tel
        case budget
        case access
        case imageUrl = "image_url"
    }
    
    /// 最寄駅と駅からの所要時間を入れるEntity
    struct Access : Decodable {
        /// 駅名
        let station: String
        
        /// 駅からの所要時間（徒歩）
        let walk: String
    }
    
    /// サムネ画像のEntity
    struct Image : Decodable {
        let shopImage: String
        
        private enum CodingKeys : String, CodingKey {
            case shopImage = "shop_image1"
        }
    }
}
