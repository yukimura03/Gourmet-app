//
//  ViewController.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/26.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let getAreaUrl = "https://api.gnavi.co.jp/master/GAreaLargeSearchAPI/v3/?keyid=a6cababca853c93d265f18664e323093"
    var areaInTokyo = [[String: Any]]()
    var areaName = [String]()
    
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "queue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        
        getAreaInfo()
        dispatchGroup.notify(queue: .main){ // 処理終わりました、を受け取ったら動く
            self.reloadData()
        }
    }
    
    /// エリア情報を取得する
    func getAreaInfo(){
        dispatchGroup.enter() // 処理始めます
        let url = URL(string: self.getAreaUrl)!
    
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
            
                let areaJson = json["garea_large"] // エリア一覧をひとかたまりとして取得
                let areaJsonAny = areaJson as! [Any] // さっきひとかたまりにしたのでAny型の配列に型キャスト
                let restaurantsData = areaJsonAny .map { (restaurantsData) -> [String: Any] in
                    return restaurantsData as! [String: Any] // Any型の配列だと中身にアクセスできないので、辞書型に変更
                }
                
                // エリアコードが１３（東京）のものだけ取り出してareaInTokyoに入れる
                for n in 0..<restaurantsData.count {
                    let pref = restaurantsData[n]["pref"]!
                    var prefString = pref as! [String: String]
                    if prefString["pref_code"] == "PREF13" {
                        self.areaInTokyo += [restaurantsData[n]]
                    }
                }
                
                // areaInTokyoからエリアの名前だけ取り出して配列に入れる
                self.areaName = self.areaInTokyo.map{$0["areaname_l"] as! String}
                self.dispatchGroup.leave() // 処理終わりました
                
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    /// テーブルビューを再読み込みしてデータを表示する
    func reloadData() {
        self.tableView.reloadData()
    }
    
    // cellの数はエリア名の数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areaName.count
    }
    
    // cellにエリア名を表示する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AreaCell", for: indexPath)
        cell.textLabel?.text = areaName[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // タップしたセルの「エリア名」「エリアコード」を次の画面に渡す
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let storeInfoView = segue.destination as! StoreInfoViewController
                storeInfoView.areaname = areaName[indexPath.row]
                storeInfoView.areacode = areaInTokyo[indexPath.row]["areacode_l"] as! String
            }
        }
    }
    
    // 前の画面から戻ってきたら、セルのハイライトが消える
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
}

