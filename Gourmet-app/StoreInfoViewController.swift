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
    
    let getApiModel = GetApiModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.storeInfoView.estimatedRowHeight = 100
        self.storeInfoView.rowHeight = UITableView.automaticDimension
        
        storeInfoView.delegate = self
        storeInfoView.dataSource = self

        getApiModel.getRestData()
        getApiModel.dispatchGroup.notify(queue: .main){ // 処理終わりました、を受け取ったら動く
            self.navigationItem.title = "\(self.getApiModel.areaname)の飲食店 \(self.getApiModel.totalHitCount.withComma)件"
            self.reloadData()
        }
    }
    
    /// テーブルビューを再読み込みする
    func reloadData() {
        self.storeInfoView.reloadData()
    }
    
    // ---テーブルビューを作る部分---
    func numberOfSections(in tableView: UITableView) -> Int {
        if getApiModel.status == 0 || getApiModel.status == 1 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if getApiModel.status == 0 {
                return 1 // 読み込み中のindicatorを見せるためのセル
            } else {
                return getApiModel.restInfo.count
            }
        } else {
            return 1 // 読み込み中のindicatorを見せるためのセル
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if getApiModel.status == 0 {
                let LoadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
                LoadingCell.indicator.startAnimating() // indicatorを表示させる
                
                return LoadingCell
            } else {
                // 1つ目のセクションの中身
                let cell = storeInfoView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as! StoreCell
                
                // サムネイルを表示させる処理
                cell.storeImage.layer.cornerRadius = cell.storeImage.frame.size.width * 0.1
                cell.storeImage.clipsToBounds = true
                let url = URL(string: getApiModel.restInfo[indexPath.row].image_url.shop_image1)
                if url != nil {
                    let data = try? Data(contentsOf: url!)
                    cell.storeImage.image = UIImage(data: data!)
                } else {
                    cell.storeImage.image = UIImage(named: "noimage")
                }
                
                // それ以外の文字を表示させる
                cell.storeName.text = getApiModel.restInfo[indexPath.row].name
                 cell.timeRequired.text = "\(getApiModel.restInfo[indexPath.row].access.station)から徒歩\(getApiModel.restInfo[indexPath.row].access.walk)分"
                 cell.address.text = getApiModel.restInfo[indexPath.row].address
                 cell.tel.text = getApiModel.restInfo[indexPath.row].tel
                 cell.budget.text = "¥\((getApiModel.restInfo[indexPath.row].budget).withComma)"
                
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
        getApiModel.dispatchGroup.notify(queue: .main) {
            
            if self.storeInfoView.contentOffset.y + self.storeInfoView.frame.size.height > self.storeInfoView.contentSize.height && self.storeInfoView.isDragging {
                
                self.getApiModel.status = 2
                
                self.reloadData()
                
                self.getApiModel.offsetPage += 1
                self.getApiModel.getRestData()
                
                self.getApiModel.dispatchGroup.notify(queue: .main) {
                    self.getApiModel.status = 1
                    self.reloadData()
                }
            }
        }
    }
}
