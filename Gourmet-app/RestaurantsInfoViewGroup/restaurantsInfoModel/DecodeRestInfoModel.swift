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
    
    enum statusType {
        /// 読み込み中
        case loading
        /// 読み込み完了
        case finish
        /// 再読み込み中
        case reloading
    }
    
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
    /// 現在の状態
    var status: statusType = .loading
    
    // エラーの時
    /// エラーコード
    var errorCode: Int = 0
    /// エラーメッセージ
    var errorMessage: String = ""
    
    /// レストランデータのJSONを取得してdecodeする
    func getRestData() {
        dispatchGroup.enter() // 処理始めます
        
        let url = URL(string: "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=\(id)&areacode_l=\(areacode)&hit_per_page=\(hitPerPage)&offset_page=\(offsetPage)")!
        
        // &areacode_l=\(areacode)&hit_per_page=\(hitPerPage)&offset_page=\(offsetPage)
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            // nilチェック
            guard let data = data, let urlResponse = urlResponse as? HTTPURLResponse else {
                // 通信エラーなどの場合
                return;
            }
            do {
                let decoder = JSONDecoder()
                
                if case (200..<300)? = (urlResponse as? HTTPURLResponse)?.statusCode{
                    let response = try decoder.decode(RestInfoModel.apiData.self, from: data)
                    
                    self.restInfo += response.rest
                    self.totalHitCount = response.total_hit_count
                    self.status = .finish
                    
                } else {
                    let response = try decoder.decode(RestInfoModel.errorData.self, from: data)
                    self.errorCode = response.error[0].code
                    self.errorMessage = response.error[0].message
                }
                
                self.dispatchGroup.leave()
            } catch {
                print("error")
            }
        }
        // リクエストを実行
        task.resume()
    }
    
}
