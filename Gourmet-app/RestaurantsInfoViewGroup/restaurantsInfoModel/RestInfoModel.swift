//
//  GetApiModel.swift
//  Gourmet-app
//
//  Created by minagi on 2019/01/20.
//  Copyright © 2019 minagi. All rights reserved.
//

import UIKit

final class RestInfoModel {
    
    /// レストラン情報から必要な項目だけを入れるEntity
    struct apiData: Codable {
        // このエリアの総店舗数
        let total_hit_count: Int
        // レストランデータ
        let rest: [restaurantsData]
    }
    
    /// restInfoCellに表示するデータを綺麗にするEntity
    struct restaurantsData: Codable {
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
        let imageUrl: image
        
        private enum CodingKeys: String, CodingKey {
            case name
            case address
            case tel
            case budget
            case access
            case imageUrl = "image_url"
        }

        /// 最寄駅と駅からの所要時間を入れるEntity
        struct Access: Codable {
            /// 駅名
            let station: String
            /// 駅からの所要時間（徒歩）
            let walk: String
        }
        
        /// サムネ画像のEntity
        struct image: Codable {
            let shopImage: String
            
            private enum CodingKeys: String, CodingKey {
                case shopImage = "shop_image1"
            }
        }
    }
    
    /// エラーの場合の情報
    struct errorData: Codable {
        let error: [ErrorMessage]
    }
    struct ErrorMessage: Codable {
        let code: Int
        let message: String
    }
    
}
