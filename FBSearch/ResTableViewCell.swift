//
//  ResTableViewCell.swift
//  FBSearch
//
//  Created by Savoki Song on 4/19/17.
//  Copyright © 2017 Yingzhao Song. All rights reserved.
//

import UIKit
import SwiftyJSON
class ResTableViewCell: UITableViewCell {
    var item: String = ""
    var id: String = ""
    var type: String = ""
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var itemName: UILabel!
    
    @IBOutlet weak var favImage: UIButton!
    @IBAction func isFavorite(_ sender: Any) {
        
        let itemIdentity: [String: String] = ["id": id, "type": type]
        let jsonItem = JSON(itemIdentity)
        let sItemIdentity: String = String(describing: jsonItem)
        if (sender as! UIButton).imageView?.image == UIImage(named: "empty") {
            UserDefaults.standard.set(item, forKey: sItemIdentity)
            (sender as! UIButton).setImage(UIImage(named: "filled"), for: UIControlState.normal)
        } else {
            (sender as! UIButton).setImage(UIImage(named: "empty"), for: UIControlState.normal)
            UserDefaults.standard.removeObject(forKey: sItemIdentity)
            UserDefaults.standard.synchronize()
        }
    }
}
