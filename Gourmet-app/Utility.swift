//
//  Utility.swift
//  Gourmet-app
//
//  Created by minagi on 2019/01/28.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

/// 3桁ずつコンマを打つextention
extension Int {
    var withComma: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let commaString = formatter.string(from: self as NSNumber)
        return commaString ?? "\(self)"
    }
}
