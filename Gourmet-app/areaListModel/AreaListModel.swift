//
//  AreaListModel.swift
//  Gourmet-app
//
//  Created by minagi on 2019/01/20.
//  Copyright © 2019 minagi. All rights reserved.
//

import UIKit

class AreaListModel {
    
    /// JSONからエリアの名前とコードだけ取り出すための箱
    struct AreaInTokyo: Codable {
        let areanameL: String
        let areacodeL: String
        
        private enum CodingKeys: String, CodingKey {
            case areanameL = "areaname_l"
            case areacodeL = "areacode_l"
        }
    }
}
