//
//  Album.swift
//  FBSearch
//
//  Created by Savoki Song on 4/19/17.
//  Copyright © 2017 Yingzhao Song. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire
import EasyToast
import FBSDKShareKit
class Album: UIViewController,UITableViewDelegate,UITableViewDataSource, FBSDKSharingDelegate {
    var detailData: JSON = [:]
    var selectedIndexPath: IndexPath?

    @IBOutlet weak var albumTableView: UITableView!
    
    @IBAction func actionSheet(_ sender: Any) {
        let aActionSheet = UIAlertController(title: "menu", message: nil, preferredStyle: .actionSheet)
        
        let itemId = JSON.parse((UserDefaults.standard.object(forKey: "details") as? String)!)["id"].string
        let itemType = UserDefaults.standard.object(forKey: "detailsType") as! String
        let itemIdentity: [String: String] = ["id": itemId!, "type": itemType]
        let jsonItem = JSON(itemIdentity)
        let sItemIdentity: String = String(describing: jsonItem)
        if UserDefaults.standard.object(forKey: sItemIdentity) == nil {
            let add2Fav = UIAlertAction(title: "Add to Favorites", style: .default, handler: addAndDelete)
            aActionSheet.addAction(add2Fav)
        } else {
            let add2Fav = UIAlertAction(title: "Remove from Favorites", style: .default, handler: addAndDelete)
            aActionSheet.addAction(add2Fav)
        }
        
        let share2FB = UIAlertAction(title: "Share", style: .default, handler: share2FBHandler)
        aActionSheet.addAction(share2FB)
        
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive)
        aActionSheet.addAction(cancelButton)
        self.present(aActionSheet, animated: true, completion: nil)
    }
    
    func share2FBHandler(_ sender: Any) {
        
        let userItem: JSON = JSON.parse((UserDefaults.standard.object(forKey: "details") as? String)!)
        let myContent :FBSDKShareLinkContent = FBSDKShareLinkContent()
        
        myContent.contentTitle = userItem["name"].string
        myContent.contentDescription = "FB Share for CSCI 571"
        let iUrl = userItem["picture"]["data"]["url"].string
        myContent.imageURL = NSURL(string: iUrl!) as URL!
        
        let shareDialog : FBSDKShareDialog = FBSDKShareDialog()
        shareDialog.mode = .feedBrowser
        shareDialog.fromViewController = self
        shareDialog.delegate = self // if you wang call back, set delegate
        shareDialog.shareContent = myContent
        if !shareDialog.canShow() {
            shareDialog.mode = .automatic
        }
        shareDialog.show()
    }
    
    func addAndDelete(_ sender: Any) {
        
        let item2add = UserDefaults.standard.object(forKey: "details") as! String
        let itemId = JSON.parse(item2add)["id"].string
        let itemType = UserDefaults.standard.object(forKey: "detailsType") as! String
        let itemIdentity: [String: String] = ["id": itemId!, "type": itemType]
        let jsonItem = JSON(itemIdentity)
        let sItemIdentity: String = String(describing: jsonItem)
        if UserDefaults.standard.object(forKey: sItemIdentity) == nil {
            UserDefaults.standard.set(item2add, forKey: sItemIdentity)
            self.view.showToast("Added to favorites!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        } else {
            UserDefaults.standard.removeObject(forKey: sItemIdentity)
            UserDefaults.standard.synchronize()
            self.view.showToast("Removed from favorites!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    public func sharerDidCancel(_ sharer: FBSDKSharing!) {
        self.view.showToast("Canceled!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        
    }
    public func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        self.view.showToast("Shared!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        
    }
    
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Swift.Error!) {
        self.view.showToast("Error!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.albumTableView.tableFooterView = UIView() //hide separator for empty rows
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let id = JSON.parse((UserDefaults.standard.object(forKey: "details") as? String)!)["id"].string
        if(id != nil) {
            let url = "https://homework9-165707.appspot.com/index.php?id=" + id!
            Alamofire.request(url).validate().responseJSON {
                response in
                if let jsonResult = response.result.value {
                    self.detailData = JSON(jsonResult)
                }
                DispatchQueue.main.async() {
                    self.albumTableView.reloadData()
                    SwiftSpinner.hide()
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

       if detailData["albums"]["data"] != JSON.null {
            self.albumTableView.backgroundView = nil
            return detailData["albums"]["data"].count
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.albumTableView.bounds.size.width, height: self.albumTableView.bounds.size.height))
            noDataLabel.text = "No Data Found."
            noDataLabel.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/0.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            self.albumTableView.backgroundView = noDataLabel
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
        if(detailData["albums"] != JSON.null) {
            cell.albumName.text = detailData["albums"]["data"][indexPath.row]["name"].string
            let imageView1 = cell.image1st
            if detailData["albums"]["data"][indexPath.row]["photos"]["data"][0]["id"] != JSON.null {
              let imageUrl = "https://graph.facebook.com/v2.8/" + detailData["albums"]["data"][indexPath.row]["photos"]["data"][0]["id"].string! + "/picture?access_token=EAAEgJzv5hZBQBANYXpFJOPHyldmOSyTL1ngcifZBTDNVFG7kLNSr0mJYnpIgWSGtxjT62olhXYJEOQKAZBBt2FrY4zop0oN4fs6KtFbu9JhybdDJiBChIat6LpFa32bdfKTdEf3D0ZAh1aITmoaclimI6ZC2FxCMZD"
              imageView1?.sd_setImage(with: URL(string: imageUrl))
            }
            let imageView2 = cell.image2rd
            if detailData["albums"]["data"][indexPath.row]["photos"]["data"][1]["id"] != JSON.null {
              let imageUrl = "https://graph.facebook.com/v2.8/" + detailData["albums"]["data"][indexPath.row]["photos"]["data"][1]["id"].string! + "/picture?access_token=EAAEgJzv5hZBQBANYXpFJOPHyldmOSyTL1ngcifZBTDNVFG7kLNSr0mJYnpIgWSGtxjT62olhXYJEOQKAZBBt2FrY4zop0oN4fs6KtFbu9JhybdDJiBChIat6LpFa32bdfKTdEf3D0ZAh1aITmoaclimI6ZC2FxCMZD"
              imageView2?.sd_setImage(with: URL(string: imageUrl))
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousIndexPath = selectedIndexPath
        if indexPath == selectedIndexPath {
            selectedIndexPath = nil // if already selected, hide it
        } else {
            selectedIndexPath = indexPath
        }
        var indexPaths: Array<IndexPath> = []
        if let previous = previousIndexPath {
            indexPaths += [previous]
        }
        if let current = selectedIndexPath {
            indexPaths += [current]
        }
        
        if indexPaths.count > 0 {
            albumTableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! AlbumCell).watchFrameChanges()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! AlbumCell).ignoreFrameChanges()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedIndexPath {
            return AlbumCell.expendedHeight
        } else {
            return AlbumCell.defaultHeight
        }
    }
    //go back
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
