//
//  DecodeRestInfoModel.swift
//  Gourmet-app
//
//  Created by minagi on 2019/01/24.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

final class DecodeRestInfoModel {
    
    /// レストランデータを１店舗ずつ区切って入れる配列
    var restInfo = [String]()
    
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

    }
    
}

