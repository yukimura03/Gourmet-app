//
//  StoreInfoView.swift
//  test-gourmet-app
//
//  Created by minagi on 2018/12/27.
//  Copyright © 2018 minagi. All rights reserved.
//

import UIKit

class StoreInfoView : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var storeInfoView: UITableView!
    let array2 = ["aiueo","sapporo","osashimi","tendon"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array2.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = storeInfoView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as! StoreCell
        cell.storeImage.layer.cornerRadius = cell.storeImage.frame.size.width * 0.1
        cell.storeImage.clipsToBounds = true
        
        cell.storeName.text = array2[indexPath.row]
        cell.storeImage.image = UIImage(named: "yudachi")
        cell.timeRequired.text = "五反田駅から徒歩10分"
        cell.address.text = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        cell.tel.text = "000-1111-1111"
        cell.budget.text = "¥3,000"
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.storeInfoView.estimatedRowHeight = 170
        self.storeInfoView.rowHeight = UITableView.automaticDimension
        
        storeInfoView.delegate = self
        storeInfoView.dataSource = self
        
    }
    
}
