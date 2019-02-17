//
//  StoreInfoView.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/27.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit
import Reachability

final class RestaurantsInfoViewController : UIViewController, UITableViewDelegate {
    
    /// レストラン情報をのせるテーブルビュー
    @IBOutlet weak var restInfoView: UITableView!
    
    let getRestData = GetRestData()
    
    var areaname = ""
    
    var areacode = ""

    let dataSource = RestInfoViewDataSource()
    
    var restDataEntity = RestDataEntity()
    
    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        connectionCheck()
        
        restInfoView.delegate = self
        restInfoView.dataSource = dataSource
        
        // cellの最大の高さを設定
        self.restInfoView.estimatedRowHeight = 100
        self.restInfoView.rowHeight = UITableView.automaticDimension
        
        // URLを作成してデータを取得、decodeして配列に入れる
        getRestData.fromGnaviAPI(areacodeL: areacode, offsetPage: 1) { response in
            
            // もしエラー（コールバックされたものがnil）だった場合、エラーメッセージを表示させる
            guard let response = response else {
                let title = "エラー"
                let message = "管理者に問い合わせてください"
                self.showAlert(title: title, message: message)
                return print ("error")
            }
            //self.restDataEntity.dispatchGroup.enter()
            
            // 正しいレスポンスを受け取ることができていた場合、
            // RestaurantsDataの配列に入れるメソッドを呼ぶ
            self.insertResponseIntoRestaurantsData(response: response)
            
        }
        
        getRestData.dispatchGroup.notify(queue: .main) {
            // データ取得と変数に代入する処理が終わったら、
            // navigationBarにエリア名と店舗総数を表示する
            self.dataSource.status = .finish
            self.reloadData()
            self.navigationItem.title = "\(self.areaname)の飲食店 \(self.restDataEntity.totalHitCount.withComma)件"
        }
        
    }
    
    /// レスポンスから総店舗数とレストランのデータを取り出し、
    /// totalHitCount（変数）とrestaurantsData（配列）に入れる
    func insertResponseIntoRestaurantsData(response: GnaviResponse<Restaurant>) {
        
        restDataEntity.totalHitCount = response.totalHitCount
        
        for data in response.rest {
            // 店舗情報を取得して配列に入れる処理
            restDataEntity.restaurantsData += [data]
        }

        getRestData.dispatchGroup.leave()
        
    }
    
    /// テーブルビューを再読み込みする
    func reloadData() {
        self.restInfoView.reloadData()
    }
    
    /// ネットに繋がっているか確認する
    func connectionCheck() {
        let reachability = Reachability()!
        if reachability.connection == .none {
            let title = "オフライン"
            let message = "通信状況を確認してください"
            showAlert(title: title, message: message)
        }
    }
    
    /// アラートでエラーメッセージを表示させる
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "戻る", style: .default) { action in
            // 「戻る」を押したらエリア選択画面に戻る
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
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
        restDataEntity.dispatchGroup.notify(queue: .main) {
            // 一番下までたどり着いたら
            if self.restInfoView.contentOffset.y + self.restInfoView.frame.size.height > self.restInfoView.contentSize.height && self.restInfoView.isDragging {
                
                // 再読み込み中ステータスに変更
                self.dataSource.status = .reloading
                
                // indicatorを表示するためにTableViewを更新する
                self.reloadData()
                
                // APIのアドレスを次のページに更新
                self.restDataEntity.offsetPage += 1
                
                //レストランデータを取得、更新
                //self.getRestData.getRestDataFromGnaviAPI()
                
                // 処理終了を受け取ったらステータスを変え、TableViewを更新する
                self.restDataEntity.dispatchGroup.notify(queue: .main) {
                    self.dataSource.status = .finish
                    self.reloadData()
                }
            }
        }
    }
    
    
    
}
