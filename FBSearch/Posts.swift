//
//  Posts.swift
//  FBSearch
//
//  Created by Savoki Song on 4/20/17.
//  Copyright © 2017 Yingzhao Song. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire
import EasyToast
import FBSDKShareKit
class Posts: UIViewController, UITableViewDelegate, UITableViewDataSource, FBSDKSharingDelegate {
    
    var detailData: JSON = [:]
    
    let dateFormatter = DateFormatter()

    @IBOutlet weak var postTableView: UITableView!
    
    @IBAction func actionSheet(_ sender: Any) {
        let aActionSheet = UIAlertController(title: "menu", message: nil, preferredStyle: .actionSheet)

        let itemId = JSON.parse((UserDefaults.standard.object(forKey: "details") as? String)!)["id"].string
        let itemType = UserDefaults.standard.object(forKey: "detailsType") as! String
        let itemIdentity: [String: String] = ["id": itemId!, "type": itemType]
        let jsonItem = JSON(itemIdentity)
        let sItemIdentity: String = String(describing: jsonItem)
        if UserDefaults.standard.object(forKey: sItemIdentity) == nil {
            let add2Fav = UIAlertAction(title: "Add to favorites", style: .default, handler: addAndDelete)
            aActionSheet.addAction(add2Fav)
        } else {
            let add2Fav = UIAlertAction(title: "Remove from favorites", style: .default, handler: addAndDelete)
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
            self.view.showToast("Removed to favorites!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
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
        self.postTableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SwiftSpinner.show("Loading data...")
        let id = JSON.parse((UserDefaults.standard.object(forKey: "details") as? String)!)["id"].string
        if(id != nil) {
            let url = "https://homework9-165707.appspot.com/index.php?id=" + id!
            Alamofire.request(url).validate().responseJSON {
                response in
                if let jsonResult = response.result.value {
                    self.detailData = JSON(jsonResult)
                }
                DispatchQueue.main.async() {
                    self.postTableView.reloadData()
                    SwiftSpinner.hide()
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.detailData["posts"] != JSON.null {
            self.postTableView.backgroundView = nil
            return self.detailData["posts"]["data"].count
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.postTableView.bounds.size.width, height: self.postTableView.bounds.size.height))
            noDataLabel.text = "No Data Found."
            noDataLabel.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            self.postTableView.backgroundView = noDataLabel
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        if(detailData["posts"] != JSON.null) {
            if detailData["posts"]["data"][indexPath.row]["message"] != JSON.null {
                cell.postWords.text = detailData["posts"]["data"][indexPath.row]["message"].string
            } else {
                cell.postWords.text = detailData["posts"]["data"][indexPath.row]["story"].string
            }
            let imageView = cell.postImage
            let imageUrl = detailData["picture"]["data"]["url"].string!
            imageView?.sd_setImage(with: URL(string: imageUrl))
            let dateString = detailData["posts"]["data"][indexPath.row]["created_time"].string!
            
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH:mm:ss+zzzz"
            let formateDate = dateFormatter.date(from: dateString)!
            dateFormatter.dateFormat = "dd MMMM yyyy HH:mm:ss"
            cell.postDate.text = dateFormatter.string(from: formateDate)
        }
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        postTableView.estimatedRowHeight = 30
        postTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
