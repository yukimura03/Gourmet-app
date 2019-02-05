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
    
    let decodeRestInfoModel = DecodeRestInfoModel()
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var timeRequired: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var budget: UILabel!
    
    /*
    func setCell(model: RestInfoModel, indexPath: indexPath) {
        
        name.text = decodeRestInfoModel.restInfo[indexPath.row].name
        timeRequired.text = "\(decodeRestInfoModel.restInfo[indexPath.row].access.station)から徒歩\(decodeRestInfoModel.restInfo[indexPath.row].access.walk)分"
        address.text = decodeRestInfoModel.restInfo[indexPath.row].address
        tel.text = decodeRestInfoModel.restInfo[indexPath.row].tel
        budget.text = "¥\((decodeRestInfoModel.restInfo[indexPath.row].budget).withComma)"
        
    }*/
}
