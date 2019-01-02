//
//  StoreInfoView.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/27.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit

class StoreInfoView : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var storeInfoView: UITableView!
    
    var restData = [[String: Any]]()
    var restInfo = [[String: Any]]()
    
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "queue")
    
    /// レストランデータ検索APIのアドレス。
    let urlString = "https://api.gnavi.co.jp/RestSearchAPI/v3/?"
    let id = "a6cababca853c93d265f18664e323093"
    let hitPerPage = 50
    var areacode = "" // 前の画面で選んだエリアのエリアコードを受け取る
    
    var areaname = "" // 前の画面で選んだエリアの名前を受け取る
    var totalHitCount = 0 // 後で選んだエリアの総件数を入れる
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.storeInfoView.estimatedRowHeight = 170
        self.storeInfoView.rowHeight = UITableView.automaticDimension
        
        storeInfoView.delegate = self
        storeInfoView.dataSource = self

        getRestData()
        dispatchGroup.notify(queue: .main){ // 処理終わりました、を受け取ったら動く
            self.reloadData()
            self.navigationItem.title = "\(self.areaname)の飲食店　\(self.totalHitCount)件"
        }
    }
    
    func getRestData() {
        dispatchGroup.enter() // 処理始めます
        
        let url = URL(string: "\(urlString)keyid=\(id)&areacode_l=\(areacode)&hit_per_page=\(hitPerPage)")!
        
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            do {
                var json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                self.totalHitCount = json["total_hit_count"] as! Int
                // この段階で、total_hit_countは取得できる
                
                // restのデータをひとかたまりで取り出して、Any型の配列に型キャスト
                // これは５０店舗のデータが１店舗ずつの塊で配列の中に入ってる
                let jsonRest = json["rest"] as! [Any]
                // Any型の配列だと中身にアクセスできないので、辞書型の配列に変更
                self.restData = jsonRest.map { (restData) -> [String: Any] in
                    return restData as! [String: Any]
                }
                
                // 表示項目は、店名、最寄り駅（徒歩何分）、住所、電話番号、予算、サムネイル画像。
                // 必要な項目だけを取りだして集めておく
                for n in 0..<self.restData.count {
                    let Access = self.restData[n]["access"] as! [String: Any]
                    let Image_url = self.restData[n]["image_url"] as! [String: Any]
                    
                    self.restInfo += [[
                        "name": self.restData[n]["name"]!,
                        "station": Access["station"]!,
                        "walk": Access["walk"]!,
                        "address": self.restData[n]["address"]!,
                        "tel": self.restData[n]["tel"]!,
                        "budget": self.restData[n]["budget"]! ,
                        "image": Image_url["shop_image1"]!
                        ]]
                }

                self.dispatchGroup.leave() // 処理終わりました
            }
            catch {
                print(error)
            }
        })
        task.resume()
    }
    
    func reloadData() {
        self.storeInfoView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = storeInfoView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as! StoreCell
        
        // サムネイルを表示させる処理
        cell.storeImage.layer.cornerRadius = cell.storeImage.frame.size.width * 0.1
        cell.storeImage.clipsToBounds = true
        let url = URL(string: restInfo[indexPath.row]["image"] as! String)
        if url != nil {
            let data = try? Data(contentsOf: url!)
            cell.storeImage.image = UIImage(data: data!)
        } else {
            cell.storeImage.image = UIImage(named: "noimage")
        }
        
        // それ以外の文字を表示させる
        cell.storeName.text = restInfo[indexPath.row]["name"] as? String
        cell.timeRequired.text = "\(restInfo[indexPath.row]["station"] as! String)から徒歩\(restInfo[indexPath.row]["walk"] as! String)分"
        cell.address.text = restInfo[indexPath.row]["address"] as? String
        cell.tel.text = restInfo[indexPath.row]["tel"] as? String
        cell.budget.text = "¥\(restInfo[indexPath.row]["budget"] as! Int)"
        
        return cell
    }
    
}
