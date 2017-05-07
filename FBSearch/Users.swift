//
//  Users.swift
//  FBSearch
//
//  Created by Savoki Song on 4/18/17.
//  Copyright © 2017 Patrick BODET. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire
import EasyToast
import CoreLocation

class Users: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var resData: JSON = [:]
    
    var curType: String = ""
    let locationManager = CLLocationManager()
    var lat: Double = 0
    var long: Double = 0
    

    @IBOutlet var previousB: UIButton!
    @IBOutlet var nextB: UIButton!
    @IBOutlet weak var ResTableView: UITableView!
    @IBOutlet weak var menu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: "cellType", options: NSKeyValueObservingOptions.new, context: nil)
        self.ResTableView.tableFooterView = UIView()
        let revealViewController = self.revealViewController()
        if ((revealViewController) != nil)
        {
            revealViewController?.rightViewRevealWidth = UIScreen.main.bounds.size.width
            revealViewController?.rightViewRevealOverdraw = 0;
            menu.target = revealViewController
            menu.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        if UserDefaults.standard.object(forKey: "isSearched") as! String != "true" {
            self.nextB.isEnabled = false
            self.previousB.isEnabled = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc:CLLocationCoordinate2D = manager.location!.coordinate
        lat = loc.latitude
        long = loc.longitude
    }
    
    func loadList(){
        self.ResTableView.reloadData()
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        viewDidAppear(true)
    }
    override func viewDidAppear(_ animated: Bool) {
        let keyword = UserDefaults.standard.object(forKey: "keyword") as? String
        curType = UserDefaults.standard.object(forKey: "cellType") as! String
        let enKeyword = keyword?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        if(keyword != nil) {
            var url = "https://homework9-165707.appspot.com/index.php?keyword=" + enKeyword! + "&type=" + curType
            if curType == "place" {
                url = "https://homework9-165707.appspot.com/index.php?keyword=" + enKeyword! + "&latitude=" + String(lat) + "&latitude=" + String(long) + "&type=place"
            }
            Alamofire.request(url).validate().responseJSON {
                response in
                if let jsonResult = response.result.value {
                    self.resData = JSON(jsonResult)
                }
                DispatchQueue.main.async() {
                    self.ResTableView.reloadData()
                    if(self.resData["paging"]["next"].string != nil) {
                        self.nextB.isEnabled = true
                    } else {
                        self.nextB.isEnabled = false
                    }
                    if(self.resData["paging"]["previous"].string != nil) {
                        self.previousB.isEnabled = true
                    } else {
                        self.previousB.isEnabled = false
                    }
                    var timeLen = 120000000
                    while timeLen > 0 {
                        timeLen = timeLen - 1;
                    }
                    SwiftSpinner.hide()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resData["data"].count > 0 {
            self.ResTableView.backgroundView = nil
            return resData["data"].count
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
        if(resData["data"] != JSON.null) {
          cell.type = curType
          cell.itemName.text = resData["data"][indexPath.row]["name"].string
          let imageView = cell.itemImage
          imageView?.sd_setImage(with: URL(string: resData["data"][indexPath.row]["picture"]["data"]["url"].string!))
            cell.item = String(describing: resData["data"][indexPath.row])
            
            cell.id = resData["data"][indexPath.row]["id"].string!
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SwiftSpinner.show("Loading data...")
        let cell = tableView.cellForRow(at: indexPath) as! ResTableViewCell
        UserDefaults.standard.set(cell.item, forKey: "details")
        UserDefaults.standard.set(curType, forKey: "detailsType")
        performSegue(withIdentifier: "details", sender: nil)
    }
    @IBAction func previousButton(_ sender: Any) {
        if resData["paging"]["previous"].string != nil {
            self.previousB.isEnabled = true
            let url = resData["paging"]["previous"].string!
            Alamofire.request(url).validate().responseJSON {
                response in
                if let jsonResult = response.result.value {
                    self.resData = JSON(jsonResult)
                }
                DispatchQueue.main.async() {
                    self.ResTableView.reloadData()
                    if(self.resData["paging"]["next"].string != nil) {
                        self.nextB.isEnabled = true
                    } else {
                        self.nextB.isEnabled = false
                    }
                    if(self.resData["paging"]["previous"].string != nil) {
                        self.previousB.isEnabled = true
                    } else {
                        self.previousB.isEnabled = false
                    }
                }
            }
        } else {
            self.previousB.isEnabled = false
        }
    }
    @IBAction func nextButton(_ sender: Any) {
        if resData["paging"]["next"].string != nil {
            self.nextB.isEnabled = true
            let url = resData["paging"]["next"].string!
            Alamofire.request(url).validate().responseJSON {
                response in
                if let jsonResult = response.result.value {
                    self.resData = JSON(jsonResult)
                }
                DispatchQueue.main.async() {
                    self.ResTableView.reloadData()
                    if(self.resData["paging"]["next"].string != nil && self.resData["data"].count > 9) {
                        self.nextB.isEnabled = true
                    } else {
                        self.nextB.isEnabled = false
                    }
                    if(self.resData["paging"]["previous"].string != nil) {
                        self.previousB.isEnabled = true
                    } else {
                        self.previousB.isEnabled = false
                    }
                }
            }
        } else {
            self.nextB.isEnabled = false
        }
    }
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "cellType")
    }
}

