//
//  GetRestData.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/11.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

final class GetRestData {
    
    var dispatchGroup = DispatchGroup()
    
    /// urlを作成して、情報を取り出して、decodeして、配列に入れる
    func fromGnaviAPI(areacodeL: String, offsetPage: Int, completion: @escaping (_ response: GnaviResponse<Restaurant>?) -> Void) {
        
        dispatchGroup.enter()
        /// 発行したAPIKey
        let keyid = "a6cababca853c93d265f18664e323093"
        
        /// １ページに載せる店舗数
        let hitPerPage = 50
        
        // APIクライアントの生成
        let client = GnaviClient()
        
        // リクエストの発行
        let request = GnaviAPI.SearchRestaurants(
            keyid: keyid,
            hitPerPage: String(hitPerPage),
            areacodeL: areacodeL,
            offsetPage: String(offsetPage))
        
        // リクエストの送信
        client.send(request: request) { result in
            switch result {
                
            // 正しい形のレスポンスを得られたら
            case let .success(response):
                // コールバック
                completion(response)
                
            // 解釈できないレスポンスorそもそもエラーを受け取った
            case let .failure(error):
                
                completion(nil)
                print(error)

            }

        }

    }
    
    
}


