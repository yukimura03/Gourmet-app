//
//  DecodeRestInfoModel.swift
//  Gourmet-app
//
//  Created by minagi on 2019/01/24.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

final class DecodeRestInfoModel {
    
    let restInfoModel = RestInfoModel()
    /// レストランデータを１店舗ずつ区切って入れる配列
    var restInfo = [RestInfoModel.restaurantsData]()
    
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "queue")
    
    /// 現在の状態 / 0=読み込み中　1=読み込み完了、2=再読み込み中
    var status = 0
    
    /// 自分で発行したKey
    let id = "a6cababca853c93d265f18664e323093"
    /// １ページに載せる店舗数
    let hitPerPage = 50
    /// 表示するページ
    var offsetPage = 1
    /// 前の画面で選んだcellのエリアコード
    var areacode = ""
    /// 前の画面で選んだcellのエリア名
    var areaname = ""
    /// 選んだエリアの総件数
    var totalHitCount = 0
    
    /// レストランデータ一覧を取得
    func getRestData() {
        dispatchGroup.enter() // 処理始めます
        
        let url = URL(string: "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=\(id)&areacode_l=\(areacode)&hit_per_page=\(hitPerPage)&offset_page=\(offsetPage)")!
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            // nilチェック
            guard let data = data, let urlResponse = urlResponse as? HTTPURLResponse else {
                // 通信エラーなどの場合
                return;
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(RestInfoModel.apiData.self, from: data)
                self.restInfo += response.rest
                self.totalHitCount = response.total_hit_count
                self.status = 1
                
                self.dispatchGroup.leave()
            } catch {
                print("error")
            }
        }
        // リクエストを実行
        task.resume()
    }
    
}
