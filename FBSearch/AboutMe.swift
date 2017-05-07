//
//  AboutMe.swift
//
//  Created by Savoki Song on 4/18/17.
//  Copyright © 2017 Patrick BODET. All rights reserved.
//

import UIKit

class AboutMe: UIViewController {
    @IBOutlet weak var menu: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let revealViewController = self.revealViewController()
        if ((revealViewController) != nil)
        {
            menu.addTarget(revealViewController, action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        }
    }
}
