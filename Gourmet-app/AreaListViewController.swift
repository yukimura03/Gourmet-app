//
//  ViewController.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/26.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit
import Foundation

class AreaListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    /// JSONからエリアの名前とコードだけ取り出すための箱です
    struct AreaInTokyo: Codable {
        let areaname_l: String
        let areacode_l: String
    }
    
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "queue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    
        /// NavigationBarのボタンの設定。店舗一覧画面で「＜」だけ表示するように設定
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        
        getAreaNameAndCode()
        
    }
    
    /// バンドル内にあるJSONデータを読み込む処理
    func getJSONData() throws -> Data? {
        guard let path = Bundle.main.path(forResource: "AreaInTokyo", ofType: "json") else { return nil }
        let url = URL(fileURLWithPath: path)
        
        return try Data(contentsOf: url)
    }
    
    /// AreaInTokyo（東京のエリア情報）を入れる配列
    var areaInTokyo: [AreaInTokyo] = []
    
    /// 読み込んだJSONデータからエリアの名前とコードを抜き出して配列にする。
    func getAreaNameAndCode() {
        guard let data = try? getJSONData() else { return }
        guard let areaData: [AreaInTokyo] = try? JSONDecoder().decode([AreaInTokyo].self, from: data!) else { return }
        // 抜き出した配列をareaInTokyoに反映させる
        areaInTokyo = areaData
        // 以下JSONファイルのデータを出力
        print(areaInTokyo.count)
        print(areaInTokyo[1].areaname_l)
    }
    
    /// テーブルビューを再読み込みしてデータを表示する
    func reloadData() {
        self.tableView.reloadData()
    }
    
    // cellの数はエリア名の数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return areaInTokyo.count
    }
    
    // cellにエリア名を表示する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AreaCell", for: indexPath)
        cell.textLabel?.text = areaInTokyo[indexPath.row].areaname_l
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // タップしたセルの「エリア名」「エリアコード」を次の画面に渡す
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let storeInfoView = segue.destination as! StoreInfoViewController
                storeInfoView.areaname = areaInTokyo[indexPath.row].areaname_l
                storeInfoView.areacode = areaInTokyo[indexPath.row].areacode_l
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

