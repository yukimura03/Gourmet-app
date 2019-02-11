//
//  StoreCell.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/28.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit

/// レストラン情報を表示するcell
final class RestInfoCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var timeRequired: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var budget: UILabel!
    
    // １つのcellに対して１店舗分のデータだけ渡す
    func setCell(model: Restaurant) {
        let image: UIImage?
        
        let urlString = model.imageUrl.shopImage
        if let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
            image = UIImage(data: data)
        } else {
            image = UIImage(named: "noimage")
        }
        shopImage.image = image
        
        // サムネイルを表示させる処理（角丸）
        shopImage.layer.cornerRadius = shopImage.frame.size.width * 0.1
        shopImage.clipsToBounds = true
        
        // それ以外の文字を表示させる
        name.text = model.name
        timeRequired.text = "\(model.access.station)から徒歩\(model.access.walk)分"
        address.text = model.address
        tel.text = model.tel
        budget.text = "¥\((model.budget).withComma)"
        
    }
 
}
