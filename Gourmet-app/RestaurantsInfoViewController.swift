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

final class RestaurantsInfoViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var restInfoView: UITableView!
    
    let restInfoModel = RestInfoModel()
    var areaname = ""
    var areacode = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.restInfoView.estimatedRowHeight = 100
        self.restInfoView.rowHeight = UITableView.automaticDimension
        
        restInfoView.delegate = self
        restInfoView.dataSource = self
        restInfoModel.areaname = areaname
        restInfoModel.areacode = areacode

        restInfoModel.getRestData()
        restInfoModel.dispatchGroup.notify(queue: .main){ // 処理終わりました、を受け取ったら動く
            self.navigationItem.title = "\(self.restInfoModel.areaname)の飲食店 \(self.restInfoModel.totalHitCount.withComma)件"
            self.reloadData()
        }
    }
    
    /// テーブルビューを再読み込みする
    func reloadData() {
        self.restInfoView.reloadData()
    }
    
    // ---テーブルビューを作る部分---
    func numberOfSections(in tableView: UITableView) -> Int {
        if restInfoModel.status == 0 || restInfoModel.status == 1 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if restInfoModel.status == 0 {
                return 1 // 読み込み中のindicatorを見せるためのセル
            } else {
                return restInfoModel.restInfo.count
            }
        } else {
            return 1 // 読み込み中のindicatorを見せるためのセル
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if restInfoModel.status == 0 {
                let LoadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
                LoadingCell.indicator.startAnimating() // indicatorを表示させる
                
                return LoadingCell
            } else {
                // 1つ目のセクションの中身
                let cell = restInfoView.dequeueReusableCell(withIdentifier: "RestInfoCell", for: indexPath) as! RestInfoCell
                
                // サムネイルを表示させる処理
                cell.shopImage.layer.cornerRadius = cell.shopImage.frame.size.width * 0.1
                cell.shopImage.clipsToBounds = true
                let url = URL(string: restInfoModel.restInfo[indexPath.row].imageUrl.shopImage)
                if url != nil {
                    let data = try? Data(contentsOf: url!)
                    cell.shopImage.image = UIImage(data: data!)
                } else {
                    cell.shopImage.image = UIImage(named: "noimage")
                }
                
                // それ以外の文字を表示させる
                cell.name.text = restInfoModel.restInfo[indexPath.row].name
                 cell.timeRequired.text = "\(restInfoModel.restInfo[indexPath.row].access.station)から徒歩\(restInfoModel.restInfo[indexPath.row].access.walk)分"
                 cell.address.text = restInfoModel.restInfo[indexPath.row].address
                 cell.tel.text = restInfoModel.restInfo[indexPath.row].tel
                 cell.budget.text = "¥\((restInfoModel.restInfo[indexPath.row].budget).withComma)"
                
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
            restInfoView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    // 一番下まできたら次のページを読み込む
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 読み込み中は動かないように、処理終わりましたを受け取ってから動くようにする
        restInfoModel.dispatchGroup.notify(queue: .main) {
            // 一番下までたどり着いたら
            if self.restInfoView.contentOffset.y + self.restInfoView.frame.size.height > self.restInfoView.contentSize.height && self.restInfoView.isDragging {
                
                // 読み込み中ステータスに変更
                self.restInfoModel.status = 2
                // indicatorを表示するためにTableViewを更新する
                self.reloadData()
                
                // APIのアドレスを次のページに更新
                self.restInfoModel.offsetPage += 1
                //レストランデータを取得、更新
                self.restInfoModel.getRestData()
                
                self.restInfoModel.dispatchGroup.notify(queue: .main) {
                    self.restInfoModel.status = 1
                    self.reloadData()
                }
            }
        }
    }
}
