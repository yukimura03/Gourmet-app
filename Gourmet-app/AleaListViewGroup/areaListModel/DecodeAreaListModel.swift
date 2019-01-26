//
//  DecodeAreaListModel.swift
//  Gourmet-app
//
//  Created by minagi on 2019/01/24.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

final class DecodeAreaListModel {
    let areaListModel = AreaListModel()
    /// AreaInTokyo（東京のエリア情報）を入れる配列
    var areaInTokyo: [AreaListModel.AreaInTokyo] = []
    
    /// バンドル内にあるJSONデータを読み込む
    func getJSONData() throws -> Data? {
        guard let path = Bundle.main.path(forResource: "AreaInTokyo", ofType: "json") else { return nil }
        let url = URL(fileURLWithPath: path)
        
        return try Data(contentsOf: url)
    }
    
    /// 読み込んだJSONデータからエリアの名前とコードだけ抜き出す
    func getAreaNameAndCode() {
        guard let data = try? getJSONData() else { return }
        guard let areaData: [AreaListModel.AreaInTokyo] = try? JSONDecoder().decode([AreaListModel.AreaInTokyo].self, from: data!) else { return }
        // 抜き出したデータをareaInTokyo（配列）に反映させる
        areaInTokyo = areaData
    }
}
