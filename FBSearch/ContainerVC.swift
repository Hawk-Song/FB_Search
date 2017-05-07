//
//  ContainerVC.swift
//
//  Created by Savoki Song on 4/18/17.
//  Copyright © 2017 Patrick BODET. All rights reserved.
//

import UIKit
import SwiftSpinner
class ContainerVC: UIViewController, UITabBarDelegate{
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    
    var curIndex: Int = 0;
    var controllers = [UINavigationController]()
    var controller: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent
        UserDefaults.standard.removeObject(forKey: "keyword")
        UserDefaults.standard.removeObject(forKey: "details")
 //       UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set("true", forKey: "searchResult")
        UserDefaults.standard.set("user", forKey: "cellType")
        UserDefaults.standard.set("false", forKey: "isSearched")
        self.revealViewController().rearViewRevealWidth = self.view.frame.width - 60
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultController = storyboard.instantiateViewController(withIdentifier: "resultViewController") as! UINavigationController
        let favoriteList = storyboard.instantiateViewController(withIdentifier: "FavController") as! UINavigationController
        controllers = [resultController, favoriteList]
        for aController: UINavigationController in controllers {
            self.addChildViewController(aController)
            let view = aController.view
            view?.frame = containerView.frame
            containerView.addSubview(view!)
        }

        let HomeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC")
        self.addChildViewController(HomeVC)
        let view = HomeVC.view
        view?.frame = containerView.frame
        containerView.addSubview(view!)
        controller = HomeVC
        tabBar.delegate = self
        tabBar.selectedItem = nil
        if(controller === HomeVC) {
            tabBar.isHidden = true
        }

    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index = tabBar.items?.index(of: item)
        if UserDefaults.standard.object(forKey: "searchResult") as! String == "true" && index != curIndex && UserDefaults.standard.object(forKey: "isSearched") as! String == "true" {
           SwiftSpinner.show("Loading data...")
        }
        curIndex = index!
        switch curIndex {
            case 0 : UserDefaults.standard.set("user", forKey: "cellType")
            case 1 : UserDefaults.standard.set("page", forKey: "cellType")
            case 2 : UserDefaults.standard.set("event", forKey: "cellType")
            case 3 : UserDefaults.standard.set("place", forKey: "cellType")
            default : UserDefaults.standard.set("group", forKey: "cellType")
        }
        var newController: UINavigationController
        if UserDefaults.standard.object(forKey: "searchResult") as! String == "true"{
          newController = controllers[0]
        } else {
          newController = controllers[1]
        }        
        swapFromViewController(controller! as! UIViewController, toViewController: newController)
    }
    
    func swapFromViewController(_ fromViewController: UIViewController, toViewController newViewController: UIViewController)
    {
        tabBar.isHidden = false
        if fromViewController !== newViewController {
            newViewController.view.frame = containerView.frame
            fromViewController.willMove(toParentViewController: nil)
            self.addChildViewController(newViewController)
            self.transition(from: fromViewController, to: newViewController, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: { (finished) in
                fromViewController.removeFromParentViewController()
                newViewController.didMove(toParentViewController: self)
                self.controller = newViewController
            })
        }
    }
}
