//
//  GetRestData.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/11.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

final class GetRestData {
    
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
    
    /// 遅延処理をする時に使う
    let dispatchGroup = DispatchGroup()
    
    // MARK: -
    
    /// urlを作成して、情報を取り出して、decodeして、配列に入れる
    func getRestDataFromGnaviAPI(completion: @escaping (_ response: GnaviResponse<Restaurant>?) -> Void) {
        dispatchGroup.enter()
        /// 発行したAPIKey
        let keyid = "a6cababca853c93d265f18664e323093"
        
        /// １ページに載せる店舗数
        let hitPerPage = 50
        
        // APIクライアントの生成
        let client = GnaviClient()
        
        // リクエストの発行
        let request = GnaviAPI.SearchRestaurants(keyid: keyid, hitPerPage: String(hitPerPage), areacodeL: areacodeL, offsetPage: String(offsetPage))
        
        
        // リクエストの送信
        client.send(request: request) { result in
            switch result {
                
            // 正しい形のレスポンスを得られたら
            case let .success(response):
                self.getTrueResponse = true
                
                // コールバック
                completion(response)
                
            // 解釈できないレスポンスorそもそもエラーを受け取った
            case let .failure(error):
                self.getTrueResponse = false
                
                completion(nil)
                print(error)
                
                self.dispatchGroup.leave()
            }
            // 処理終わりましたの通知
            //self.dispatchGroup.leave()
        }

    }
    
    
}


