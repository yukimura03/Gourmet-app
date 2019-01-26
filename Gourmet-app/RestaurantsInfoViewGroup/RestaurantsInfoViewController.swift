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
    let decodeRestInfoModel = DecodeRestInfoModel()
    
    var areaname = ""
    var areacode = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.restInfoView.estimatedRowHeight = 100
        self.restInfoView.rowHeight = UITableView.automaticDimension
        
        restInfoView.delegate = self
        restInfoView.dataSource = self
        decodeRestInfoModel.areaname = areaname
        decodeRestInfoModel.areacode = areacode
        
        decodeRestInfoModel.getRestData()
        decodeRestInfoModel.dispatchGroup.notify(queue: .main){ // 処理終わりました、を受け取ったら動く
            self.navigationItem.title = "\(self.decodeRestInfoModel.areaname)の飲食店 \(self.decodeRestInfoModel.totalHitCount.withComma)件"
            self.reloadData()
        }
    }
    
    /// テーブルビューを再読み込みする
    func reloadData() {
        self.restInfoView.reloadData()
    }
    
    // ---テーブルビューを作る部分---
    func numberOfSections(in tableView: UITableView) -> Int {
        if decodeRestInfoModel.status == 0 || decodeRestInfoModel.status == 1 {
            return 1
        } else {
            return 2
        }
    }
    
    enum Section: Int {
        case contents = 0
        case indicator = 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if decodeRestInfoModel.status == 0 {
                return 1 // 読み込み中のindicatorを見せるためのセル
            } else {
                return decodeRestInfoModel.restInfo.count
            }
        } else {
            return 1 // 読み込み中のindicatorを見せるためのセル
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if decodeRestInfoModel.status == 0 {
                return self.setupIndicatorCell(indexPath: indexPath)
            } else {
                return self.setupContentsCell(indexPath: indexPath)
            }
        } else {
            return self.setupIndicatorCell(indexPath: indexPath)
        }
    }
    
    /// indicatorを表示させる
    private func setupIndicatorCell(indexPath: IndexPath) -> UITableViewCell {
        let LoadingCell = restInfoView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
        LoadingCell.indicator.startAnimating() // indicatorを表示させる
        
        return LoadingCell
    }
    
    /// cellにレストラン情報を表示させる
    private func setupContentsCell(indexPath: IndexPath) -> UITableViewCell {
        // 1つ目のセクションの中身
        let cell = restInfoView.dequeueReusableCell(withIdentifier: "RestInfoCell", for: indexPath) as! RestInfoCell
        
        // サムネイルを表示させる処理
        cell.shopImage.layer.cornerRadius = cell.shopImage.frame.size.width * 0.1
        cell.shopImage.clipsToBounds = true
        let url = URL(string: decodeRestInfoModel.restInfo[indexPath.row].imageUrl.shopImage)
        if url != nil {
            let data = try? Data(contentsOf: url!)
            cell.shopImage.image = UIImage(data: data!)
        } else {
            cell.shopImage.image = UIImage(named: "noimage")
        }
        
        // それ以外の文字を表示させる
        cell.name.text = decodeRestInfoModel.restInfo[indexPath.row].name
        cell.timeRequired.text = "\(decodeRestInfoModel.restInfo[indexPath.row].access.station)から徒歩\(decodeRestInfoModel.restInfo[indexPath.row].access.walk)分"
        cell.address.text = decodeRestInfoModel.restInfo[indexPath.row].address
        cell.tel.text = decodeRestInfoModel.restInfo[indexPath.row].tel
        cell.budget.text = "¥\((decodeRestInfoModel.restInfo[indexPath.row].budget).withComma)"
        
        return cell
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
        decodeRestInfoModel.dispatchGroup.notify(queue: .main) {
            // 一番下までたどり着いたら
            if self.restInfoView.contentOffset.y + self.restInfoView.frame.size.height > self.restInfoView.contentSize.height && self.restInfoView.isDragging {
                
                // 読み込み中ステータスに変更
                self.decodeRestInfoModel.status = 2
                // indicatorを表示するためにTableViewを更新する
                self.reloadData()
                
                // APIのアドレスを次のページに更新
                self.decodeRestInfoModel.offsetPage += 1
                //レストランデータを取得、更新
                self.decodeRestInfoModel.getRestData()
                
                self.decodeRestInfoModel.dispatchGroup.notify(queue: .main) {
                    self.decodeRestInfoModel.status = 1
                    self.reloadData()
                }
            }
        }
    }
}
