//
//  HomeVC.swift
//  FBSearch
//  Created by Savoki Song on 4/18/17.
//  Copyright © 2017 Patrick BODET. All rights reserved.
//

import UIKit
import SwiftSpinner
import EasyToast
class HomeVC: UIViewController {
    var containerController: ContainerVC?    
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var revealButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
    }

    @IBAction func clearButton(_ sender: Any) {
        keyword.text = ""
    }

    @IBAction func searchButton(_ sender: Any) {
        
        if keyword.text == "" {
            self.view.showToast("Enter a valid query!", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
            return
        }
        UserDefaults.standard.set(keyword.text, forKey: "keyword")
        UserDefaults.standard.set("true", forKey: "isSearched")
        SwiftSpinner.show("Loading data...")
        
        containerController = revealViewController().frontViewController as? ContainerVC

        containerController?.tabBar.selectedItem = containerController?.tabBar.items![0]  //what does this line for?
        
        containerController?.swapFromViewController(containerController!.controller as! UIViewController, toViewController: containerController!.controllers[0])
        UserDefaults.standard.set("user", forKey: "cellType")        
        revealViewController().pushFrontViewController(containerController,animated:true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserDefaults.standard.set("true", forKey: "searchResult")        
        let revealViewController = self.revealViewController()
        if ((revealViewController) != nil)
        {
            revealButton.addTarget(revealViewController, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        }
    }
}
