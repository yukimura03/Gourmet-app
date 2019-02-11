//
//  SectionType.swift
//  Gourmet-app
//
//  Created by minagi on 2019/02/11.
//  Copyright © 2019 minagi. All rights reserved.
//

import Foundation

enum SectionType: Int {
    /// 基本の（レストランデータを表示する）セクション
    case contents = 0
    
    /// 読み込み中のインジケータを表示する時に出てくるセクション
    case indicator
}
