//
//  ViewController.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/26.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit
import Foundation

final class AreaListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var areaListView: UITableView!
    
    let areaListModel = AreaListModel()
    let decodeAreaListModel = DecodeAreaListModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        areaListView.delegate = self
        areaListView.dataSource = self
    
        /// NavigationBarのボタンの設定。店舗一覧画面で「＜」だけ表示するように設定
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        
        decodeAreaListModel.getAreaNameAndCode()
    }
    
    // ---テーブルビューを作る部分---
    // cellの数はエリア名の数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decodeAreaListModel.areaInTokyo.count
    }
    // cellにエリア名を表示する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.setupListCell(indexPath: indexPath)
    }
    /// エリア一覧が載ったセルを表示する
    private func setupListCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = areaListView.dequeueReusableCell(withIdentifier: "AreaCell", for: indexPath)
        cell.textLabel?.text = decodeAreaListModel.areaInTokyo[indexPath.row].areanameL
        return cell
    }
    // ---ここまで---
    
    /// テーブルビューを再読み込みする
    func reloadData() {
        self.areaListView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // タップしたセルの「エリア名」「エリアコード」を次の画面に渡す
        if segue.identifier == "showDetail" {
            if let indexPath = areaListView.indexPathForSelectedRow {
                let restInfoVC = segue.destination as! RestaurantsInfoViewController
                restInfoVC.areaname = decodeAreaListModel.areaInTokyo[indexPath.row].areanameL
                restInfoVC.areacode = decodeAreaListModel.areaInTokyo[indexPath.row].areacodeL
            }
        }
    }
    
    // 前の画面から戻ってきたら、セルのハイライトが消える
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPathForSelectedRow = areaListView.indexPathForSelectedRow {
            areaListView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
}

