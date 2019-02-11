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
    
    /// レストラン情報をのせるテーブルビュー
    @IBOutlet weak var restInfoView: UITableView!
    
    let reachability = Reachability()!
    let getRestData = GetRestData()
    
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
        
        getRestData.areacodeL = areacode

        // URLを作成してデータを取得、decodeして配列に入れる
        getRestData.getRestDataFromGnaviAPI()
        
        getRestData.dispatchGroup.notify(queue: .main) {
            self.getRestData.status = .finish
            self.navigationItem.title = "\(self.areaname)の飲食店 \(self.getRestData.totalHitCount.withComma)件"
            self.reloadData()
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
    
    /* --- テーブルビューの要素--- */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if getRestData.status == .loading {
            return self.setupIndicatorCell(indexPath: indexPath)
        } else {
            return self.setupContentsCell(indexPath: indexPath)
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
        
        cell.setCell(model: getRestData.restaurantsData[indexPath.row])
        
        return cell
    }
    
}
