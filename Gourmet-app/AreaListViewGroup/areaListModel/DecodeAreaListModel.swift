//
//  DecodeAreaListModel.swift
//  Gourmet-app
//
//  Created by minagi on 2019/01/24.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

final class DecodeAreaListModel {

    /// decode済みのエリア情報を入れる配列
    var areaInTokyo: [AreaInTokyo] = []
    
    /// バンドル内にあるJSONデータを読み込む
    func getJSONData() throws -> Data? {
        guard let path = Bundle.main.path(forResource: "AreaInTokyo", ofType: "json") else { return nil }
        let url = URL(fileURLWithPath: path)
        
        return try Data(contentsOf: url)
    }
    
    /// JSONファイルを読み込み、decodeしてエリアの名前とコードだけ抜き出す
    func getAreaNameAndCode() {
        guard let data = try? getJSONData() else { return }
        guard let areaData: [AreaInTokyo] = try? JSONDecoder().decode([AreaInTokyo].self, from: data!) else { return }
        // 抜き出したデータをareaInTokyo（配列）に反映させる
        areaInTokyo = areaData
    }
}
