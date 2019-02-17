//
//  RestInfoViewDataSource.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/15.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation
import UIKit

class RestInfoViewDataSource: NSObject, UITableViewDataSource {
    
    var restDataEntity = RestDataEntity()
    
    var num = 0
    
    /// 取得してdecodeしたレストランデータを入れる配列
    var restaurantsData = [Restaurant]()
    
    /// 現在のステータス
    var status: StatusType = .loading
    
    /* --- テーブルビューの要素--- */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch status {
        // ページを開いて読み込み中の時はloadingCellのみ表示
        case .loading:
            return 1
            
        // 読み込み完了時はレストラン情報のcellのみ表示
        case .finish:
            return 1
            
        // 一番下まで来て再読み込みする時はレストラン情報＋loadigCellの両方を表示する
        case .reloading:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SectionType(rawValue: section) {
            
        case .some(.contents):
            switch status {
            // 読み込み中の時はloadingCellを１つだけ表示する
            case .loading:
                return 1
                
            // 読み込み完了時は読み込んだレストラン数分のcellを表示する
            case .finish:
                print("ここ", restaurantsData.count)
                return restaurantsData.count
                
            // 再読み込み中は読み込んだレストラン数分のcellを表示する
            case .reloading:
                return restDataEntity.restaurantsData.count
            }
            
        case .some(.indicator):
            // 読み込み中のcellは常に一つだけ
            return 1
            
        case .none:
            fatalError("section数は３つ以上にはなりません。")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // エラー処理
        guard let section = SectionType(rawValue: indexPath.section) else {
            return tableView.dequeueReusableCell(withIdentifier: "Undefined Section", for: indexPath)
        }
        
        switch section {
        case .contents:
            if status == .loading {
                return self.setupIndicatorCell(tableView: tableView, indexPath: indexPath)
            } else {
                return self.setupContentsCell(tableView: tableView, indexPath: indexPath)
            }
            
        case .indicator:
            return self.setupIndicatorCell(tableView: tableView, indexPath: indexPath)
        }
    }
    
    /* --- cellを作る部分 --- */
    /// cellにindicatorを表示させる
    private func setupIndicatorCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let LoadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
        
        LoadingCell.indicator.startAnimating() // indicatorを表示させる
        
        return LoadingCell
    }
    
    /// cellにレストラン情報を表示させる
    private func setupContentsCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        // 1つ目のセクションの中身
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestInfoCell", for: indexPath) as! RestInfoCell
        
        cell.setCell(model: restaurantsData[indexPath.row])
        return cell
    }
}
