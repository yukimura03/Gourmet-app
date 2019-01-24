//
//  LoadingCell.swift
//  test-gourmet-app
//
//  Created by minagi on 2019/01/04.
//  Copyright © 2019 minagi. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    var indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        indicator.startAnimating()
        addSubview(indicator)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        var x = bounds.width/2
        if newSuperview != nil {
            x = (newSuperview?.bounds.width)!/2
        }
        let y = bounds.size.height/2
        indicator.center = CGPoint(x: x, y: y)
    }
}
