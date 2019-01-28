//
//  StoreInfoView.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/27.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit

final class RestaurantsInfoViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var restInfoView: UITableView!
    
    let restInfoModel = RestInfoModel()
    let decodeRestInfoModel = DecodeRestInfoModel()
    
    var areaname = ""
    var areacode = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        restInfoView.delegate = self
        restInfoView.dataSource = self
        
        // cellの最大の高さを設定
        self.restInfoView.estimatedRowHeight = 100
        self.restInfoView.rowHeight = UITableView.automaticDimension
        
        // 前の画面で選んだエリア情報をModelに渡す
        decodeRestInfoModel.areaname = areaname
        decodeRestInfoModel.areacode = areacode
        
        decodeRestInfoModel.getRestData()
        // 処理終わりました、を受け取ったら動く
        decodeRestInfoModel.dispatchGroup.notify(queue: .main){
            self.navigationItem.title = "\(self.decodeRestInfoModel.areaname)の飲食店 \(self.decodeRestInfoModel.totalHitCount.withComma)件"
            self.reloadData()
        }
    }
    
    /// テーブルビューを再読み込みする
    func reloadData() {
        self.restInfoView.reloadData()
    }
    
    /* ---テーブルビューを作る部分--- */
    enum sectionType: Int {
        case contents = 0
        case indicator
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if decodeRestInfoModel.status == .reloading {
            return 2
        } else {    // loadingとfinishの時
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionType(rawValue: section) == .some(.contents){
            if decodeRestInfoModel.status == .loading {
                // inidicatorのcellを一つだけ表示させる
                return 1
            } else { // finishとreloadingの時
                // 店舗数分のcellを表示する
                return decodeRestInfoModel.restInfo.count
            }
        } else { // sectionType.indicator
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // エラー処理
        guard let safeSection = sectionType(rawValue: indexPath.section) else {
            return tableView.dequeueReusableCell(withIdentifier: "Undefined Section", for: indexPath)
        }
        if safeSection == .contents {
            if decodeRestInfoModel.status == .loading {
                return self.setupIndicatorCell(indexPath: indexPath)
            } else {
                return self.setupContentsCell(indexPath: indexPath)
            }
        } else {
            return self.setupIndicatorCell(indexPath: indexPath)
        }
    }
    
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
        
        // サムネイルを表示させる処理（角丸）
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
    /* ---ここまで--- */
    
    // 選択したセルのハイライトを消す
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
                self.decodeRestInfoModel.status = .reloading
                // indicatorを表示するためにTableViewを更新する
                self.reloadData()
                
                // APIのアドレスを次のページに更新
                self.decodeRestInfoModel.offsetPage += 1
                //レストランデータを取得、更新
                self.decodeRestInfoModel.getRestData()
                
                self.decodeRestInfoModel.dispatchGroup.notify(queue: .main) {
                    self.decodeRestInfoModel.status = .finish
                    self.reloadData()
                }
            }
        }
    }
}
