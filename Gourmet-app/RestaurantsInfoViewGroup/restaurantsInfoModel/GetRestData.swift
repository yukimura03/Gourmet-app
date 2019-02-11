//
//  GetRestData.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/11.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

final class GetRestData {
    
    /// 自分で発行したKey
    let keyid = "a6cababca853c93d265f18664e323093"
    
    /// １ページに載せる店舗数
    let hitPerPage = 50
    
    /// 表示するページ
    var offsetPage = 1
    
    /// 前の画面で選んだcellのエリアコード
    var areacodeL = ""
    
    /// 選んだエリアの総件数
    var totalHitCount = 0
    
    /// 現在の状態
    var status: StatusType = .loading
    
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "queue")
    
    var restaurantsData = [Restaurant]()
    
    
    func getRestDataFromGnaviAPI() {
        // 処理始めます
        dispatchGroup.enter()
        
        // APIクライアントの生成
        let client = GnaviClient()
        
        // リクエストの発行
        let request = GnaviAPI.SearchRestaurants(keyid: keyid, hitPerPage: String(hitPerPage), areacodeL: areacodeL, offsetPage: String(offsetPage))
        
        // リクエストの送信
        client.send(request: request) { result in
            switch result {
                
            // 正しい形のレスポンスを得られたら
            case let .success(response):
                self.totalHitCount = response.totalHitCount
                for data in response.rest {
                    // 店舗情報を取得して配列に入れる処理
                    self.restaurantsData += [data]
                }
                // 処理終わりましたの通知
                self.dispatchGroup.leave()
                
            // 解釈できないレスポンスorそもそもエラーを受け取った
            case let .failure(error):
                // エラー詳細を出力
                print("どこかがおかしい: ", error)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print(self.restaurantsData)
        }
        
    }
    
    
}


