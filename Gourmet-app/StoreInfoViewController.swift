//
//  StoreInfoView.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/27.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit

/// 3桁ずつコンマを打つextention
extension Int {
    var withComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let commaString = formatter.string(from: self as NSNumber)
        return commaString ?? "\(self)"
    }
}

final class StoreInfoViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var storeInfoView: UITableView!
    
    /// レストラン情報から必要な項目だけを抜き出す箱です
    struct apiData: Codable {
        let total_hit_count: Int
        let rest: [restaurantsData]
    }
    
    struct restaurantsData: Codable {
        let name: String
        let address: String
        let tel: String
        let budget: Int
        let access: Access
        let image_url: image
        
        struct Access: Codable {
            let station: String
            let walk: String
        }
        
        struct image: Codable {
            let shop_image1: String
        }
    }
    
    let dispatchGroup2 = DispatchGroup()
    let dispatchQueue2 = DispatchQueue(label: "queue")
    
    /// 自分で発行したKey
    let id = "a6cababca853c93d265f18664e323093"
    /// １ページに載せる店舗数
    let hitPerPage = 50
    /// 何ページ目
    var offsetPage = 1
    /// 前の画面で選んだエリアのエリアコードを受け取る
    var areacode = ""
    /// 前の画面で選んだエリアの名前を受け取る
    var areaname = ""
    /// 選んだエリアの総件数を入れる
    var totalHitCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.storeInfoView.estimatedRowHeight = 100
        self.storeInfoView.rowHeight = UITableView.automaticDimension
        
        storeInfoView.delegate = self
        storeInfoView.dataSource = self

        getRestData()
        dispatchGroup2.notify(queue: .main){ // 処理終わりました、を受け取ったら動く
            self.navigationItem.title = "\(self.areaname)の飲食店 \(self.totalHitCount.withComma)件"
            self.reloadData()
        }
    }
    
    var restInfo = [restaurantsData]()
    
    /// レストランデータ一覧を取得
    func getRestData() {
        dispatchGroup2.enter() // 処理始めます
        
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
                let response = try decoder.decode(apiData.self, from: data)
                self.restInfo += response.rest
                self.totalHitCount = response.total_hit_count
                self.status = 1
                
                self.dispatchGroup2.leave()
            } catch {
                print("error")
                return;
            }
        }
        // リクエストを実行
        task.resume()
    }
    /// テーブルビューを再読み込みする
    func reloadData() {
        self.storeInfoView.reloadData()
    }
    
    // ---テーブルビューを作る部分---
    /// 0=読み込み中　1=読み込み完了、2=再読み込み中
    var status = 0
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if status == 0 || status == 1 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if status == 0 {
                return 1
            } else {
                return restInfo.count
            }
        } else {
            return 1 // 読み込み中のindicatorを見せるためのやつ
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if status == 0 {
                let LoadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
                LoadingCell.indicator.startAnimating() // indicatorを表示させる
                
                return LoadingCell
            } else {
                // 1つ目のセクションの中身
                let cell = storeInfoView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as! StoreCell
                
                // サムネイルを表示させる処理
                cell.storeImage.layer.cornerRadius = cell.storeImage.frame.size.width * 0.1
                cell.storeImage.clipsToBounds = true
                let url = URL(string: restInfo[indexPath.row].image_url.shop_image1)
                if url != nil {
                    let data = try? Data(contentsOf: url!)
                    cell.storeImage.image = UIImage(data: data!)
                } else {
                    cell.storeImage.image = UIImage(named: "noimage")
                }
                
                // それ以外の文字を表示させる
                cell.storeName.text = restInfo[indexPath.row].name
                 cell.timeRequired.text = "\(restInfo[indexPath.row].access.station)から徒歩\(restInfo[indexPath.row].access.walk)分"
                 cell.address.text = restInfo[indexPath.row].address
                 cell.tel.text = restInfo[indexPath.row].tel
                 cell.budget.text = "¥\((restInfo[indexPath.row].budget).withComma)"
                
                return cell
            }
        } else {
            // 2つ目のセクションの中身
            let LoadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
            LoadingCell.indicator.startAnimating() // indicatorを表示させる
            
            return LoadingCell
        }
    }   
    // ---ここまで---
    
    // 選択したセルの色を戻す
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            storeInfoView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    // 一番下まできたら次のページを読み込む
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 読み込み中は動かないように、処理終わりましたを受け取ってから動くようにする
        dispatchGroup2.notify(queue: .main) {
            
            if self.storeInfoView.contentOffset.y + self.storeInfoView.frame.size.height > self.storeInfoView.contentSize.height && self.storeInfoView.isDragging {
                
                self.status = 2
                self.reloadData()
                
                self.offsetPage += 1
                self.getRestData()
                
                self.dispatchGroup2.notify(queue: .main) {
                    self.status = 1
                    self.reloadData()
                }
            }
        }
    }
}
