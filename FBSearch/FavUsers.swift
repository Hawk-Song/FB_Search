//
//  FavUsers.swift
//  FBSearch
//
//  Created by Savoki Song on 4/21/17.
//  Copyright © 2017 Yingzhao Song. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import EasyToast
class FavUsers: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var previousB: UIButton!
    
    @IBOutlet var nextB: UIButton!
    
    @IBOutlet weak var ResTableView: UITableView!
    
    @IBOutlet weak var menu: UIBarButtonItem!
    var favList: [String] = []
    var index: Int = 0
    var curType: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ResTableView.tableFooterView = UIView()
        UserDefaults.standard.addObserver(self, forKeyPath: "cellType", options: NSKeyValueObservingOptions.new, context: nil)
        let revealViewController = self.revealViewController()
        if (( revealViewController ) != nil)
        {
            menu.target = revealViewController
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        viewDidAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        favList.removeAll()
        curType = UserDefaults.standard.object(forKey: "cellType") as! String
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            if String(describing: JSON.parse(key)["type"]) == curType {
                favList.append(value as! String)
            }
        }
        if index > 0 {
            self.previousB.isEnabled = true
        } else {
            self.previousB.isEnabled = false
        }
        if favList.count - index * 10 > 10 {
            self.nextB.isEnabled = true
        } else {
            self.nextB.isEnabled = false
        }
        self.ResTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favList.count > 0 {
            self.ResTableView.backgroundView = nil
            if favList.count - 10 * index > 10 {
                return 10
            } else {
                return favList.count - 10 * index
            }
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.ResTableView.bounds.size.width, height: self.ResTableView.bounds.size.height))
            noDataLabel.text = "No Data Found."
            noDataLabel.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            self.ResTableView.backgroundView = noDataLabel
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ResTableViewCell", owner: self, options: nil)?.first as! ResTableViewCell
        if favList.count > 0 {
            cell.type = curType
            cell.itemName.text = JSON.parse(favList[indexPath.row + index * 10])["name"].string
            let imageView = cell.itemImage
            imageView?.sd_setImage(with: URL(string: JSON.parse(favList[indexPath.row + index * 10])["picture"]["data"]["url"].string!))
            cell.item = favList[indexPath.row + index * 10]
            
            cell.id = JSON.parse(favList[indexPath.row + index * 10])["id"].string!
            let itemIdentity: [String: String] = ["id": cell.id, "type": cell.type]
            let jsonItem = JSON(itemIdentity)
            let sItemIdentity: String = String(describing: jsonItem)
            if UserDefaults.standard.object(forKey: sItemIdentity) != nil {
                cell.favImage.setImage(UIImage(named: "filled"), for: UIControlState.normal)
            } else {
                cell.favImage.setImage(UIImage(named: "empty"), for: UIControlState.normal)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SwiftSpinner.show("Loading data...")
        let cell = tableView.cellForRow(at: indexPath) as! ResTableViewCell
        UserDefaults.standard.set(cell.item, forKey: "details")
        UserDefaults.standard.set(curType, forKey: "detailsType")
        performSegue(withIdentifier: "details", sender: nil)
    }
    
    @IBAction func previousButton(_ sender: Any) {
        if index > 0 {
            index = index - 1
            if index > 0 {
                self.previousB.isEnabled = true
            } else {
                self.previousB.isEnabled = false
            }
        } else {
            self.previousB.isEnabled = false
        }
        if favList.count - index * 10 > 10 {
            self.nextB.isEnabled = true
        } else {
            self.nextB.isEnabled = false
        }
        self.ResTableView.reloadData()
    }
    
    @IBAction func nextButton(_ sender: Any) {
        if favList.count - index * 10 > 10 {
            index = index + 1
            if favList.count - index * 10 > 10 {
                self.nextB.isEnabled = true
            } else {
                self.nextB.isEnabled = false
            }
        } else {
            self.nextB.isEnabled = false
        }
        if index > 0 {
            self.previousB.isEnabled = true
        } else {
            self.previousB.isEnabled = false
        }
        self.ResTableView.reloadData()
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "cellType")
    }

}
