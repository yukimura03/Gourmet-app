//
//  RestDataEntity.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/17.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

struct RestDataEntity {
    /// 表示するページ
    var offsetPage = 1
    
    /// 前の画面で選んだcellのエリアコード
    var areacodeL = ""
    
    /// 選んだエリアの総件数
    var totalHitCount = 0
    
    /// 取得してdecodeしたレストランデータを入れる配列
    var restaurantsData = [Restaurant]()
    
    /// 正しいレスポンスを受け取ることができたかどうか
    var getTrueResponse = true
    
}
