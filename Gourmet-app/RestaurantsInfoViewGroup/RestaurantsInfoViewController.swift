//
//  StoreInfoView.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/27.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit
import Reachability

final class RestaurantsInfoViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var restInfoView: UITableView!
    
    let restInfoModel = RestInfoModel()
    let decodeRestInfoModel = DecodeRestInfoModel()
    let reachability = Reachability()!
    
    var areaname = ""
    var areacode = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        connectionCheck()
        
        restInfoView.delegate = self
        restInfoView.dataSource = self
        
        // cellの最大の高さを設定
        self.restInfoView.estimatedRowHeight = 100
        self.restInfoView.rowHeight = UITableView.automaticDimension
        
        // 前の画面で選んだエリア情報をModelに渡す
        decodeRestInfoModel.areaname = areaname
        decodeRestInfoModel.areacode = areacode
        
        decodeRestInfoModel.getRestData()
        // 処理終わりました、を受け取ったら動く
        decodeRestInfoModel.dispatchGroup.notify(queue: .main){
            if self.decodeRestInfoModel.errorMessage == "" {
                self.navigationItem.title = "\(self.decodeRestInfoModel.areaname)の飲食店 \(self.decodeRestInfoModel.totalHitCount.withComma)件"
                self.reloadData()
            } else {
                self.alertTitle = String(self.decodeRestInfoModel.errorCode)
                self.alertMessage = self.decodeRestInfoModel.errorMessage
                self.showAlert()
            }
        }
    }
    
    /// テーブルビューを再読み込みする
    func reloadData() {
        self.restInfoView.reloadData()
    }
    
    var alertTitle = ""
    var alertMessage = ""
    
    /// アラートでエラーメッセージを表示させる
    func showAlert(){
        let alertController = UIAlertController(title: "エラー：\(alertTitle)", message: alertMessage, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { action in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// ネットに繋がっているか確認する
    func connectionCheck() {
        if reachability.connection == .none {
            alertTitle = "オフライン"
            alertMessage = "通信状況を確認してください"
            showAlert()
        }
    }
    
    // 選択したセルのハイライトを消す
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            restInfoView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    // 一番下まできたら次のページを読み込む
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 読み込み中は動かないように、処理終わりましたを受け取ってから動くようにする
        decodeRestInfoModel.dispatchGroup.notify(queue: .main) {
            // 一番下までたどり着いたら
            if self.restInfoView.contentOffset.y + self.restInfoView.frame.size.height > self.restInfoView.contentSize.height && self.restInfoView.isDragging {
                
                // 読み込み中ステータスに変更
                self.decodeRestInfoModel.status = .reloading
                // indicatorを表示するためにTableViewを更新する
                self.reloadData()
                
                // APIのアドレスを次のページに更新
                self.decodeRestInfoModel.offsetPage += 1
                //レストランデータを取得、更新
                self.decodeRestInfoModel.getRestData()
                
                self.decodeRestInfoModel.dispatchGroup.notify(queue: .main) {
                    self.decodeRestInfoModel.status = .finish
                    self.reloadData()
                }
            }
        }
    }
    
    /* --- テーブルビューを作る部分 --- */
    enum sectionType: Int {
        case contents = 0
        case indicator
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch decodeRestInfoModel.status {
        case .loading:
            return 1
        case .finish:
            return 1
        case .reloading:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionType(rawValue: section) {
        case .some(.contents):
            switch decodeRestInfoModel.status {
            case .loading:
                return 1
            case .finish:
                return decodeRestInfoModel.restInfo.count
            case .reloading:
                return decodeRestInfoModel.restInfo.count
            }
        case .some(.indicator):
            return 1
        case .none:
            fatalError("section数は３以上にはなりません。")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // エラー処理
        guard let safeSection = sectionType(rawValue: indexPath.section) else {
            return tableView.dequeueReusableCell(withIdentifier: "Undefined Section", for: indexPath)
        }
        switch safeSection {
        case .contents:
            if decodeRestInfoModel.status == .loading {
                return self.setupIndicatorCell(indexPath: indexPath)
            } else {
                return self.setupContentsCell(indexPath: indexPath)
            }
        case .indicator:
            return self.setupIndicatorCell(indexPath: indexPath)
        }
    }
    
    /* --- cellを作る部分 --- */
    /// cellにindicatorを表示させる
    private func setupIndicatorCell(indexPath: IndexPath) -> UITableViewCell {
        let LoadingCell = restInfoView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
        LoadingCell.indicator.startAnimating() // indicatorを表示させる
        
        return LoadingCell
    }
    
    /// cellにレストラン情報を表示させる
    private func setupContentsCell(indexPath: IndexPath) -> UITableViewCell {
        // 1つ目のセクションの中身
        let cell = restInfoView.dequeueReusableCell(withIdentifier: "RestInfoCell", for: indexPath) as! RestInfoCell
        
        cell.setCell(model: decodeRestInfoModel.restInfo[indexPath.row])
        
        return cell
    }
}
