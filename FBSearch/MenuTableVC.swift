//
//  MenuTableVC.swift
//
//  Created by Savoki Song on 4/18/17.
//  Copyright © 2017 Patrick BODET. All rights reserved.
//

import UIKit

class MenuTableVC: UITableViewController {
    
    var containerController: ContainerVC?
    struct section {
        var sectionName: String!
        var sectionContents:[String]!
    }
    var sections = [section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView() //hide separator for empty rows
        sections = [section(sectionName:"", sectionContents: ["FB Search"]), section(sectionName:" ", sectionContents: []), section(sectionName:"MENU", sectionContents: ["Home", "Favorites"]), section(sectionName:" ", sectionContents: []), section(sectionName:"OTHERS", sectionContents: ["About me"])]
        containerController = revealViewController().frontViewController as? ContainerVC
        self.clearsSelectionOnViewWillAppear = false
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].sectionContents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MenuTableCell
        if sections[indexPath.section].sectionContents[indexPath.row] != "About me" {
             cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell", for: indexPath) as! MenuTableCell
        } else {            
             let aCell = tableView.dequeueReusableCell(withIdentifier: "AboutMeTableCell", for: indexPath) as! AboutMeTableCellTableViewCell
             aCell.menuCellLabel.text = sections[indexPath.section].sectionContents[indexPath.row]
            return aCell
        }
            cell.menuCellLabel.text = sections[indexPath.section].sectionContents[indexPath.row]
            var iname: String = ""
            let labelText = cell.menuCellLabel.text!
            switch labelText {
            case "FB Search":  iname = "fb"
            case "Home":  iname = "home"
            case "Favorites":  iname = "favorite"
            default: iname = ""
            }
            cell.menuCellImage.image = UIImage(named: iname)
            return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].sectionName
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Helvetica", size: 12)
        header.textLabel?.textColor = UIColor.lightGray
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.section == 0 {
           UserDefaults.standard.set("true", forKey: "searchResult")
           containerController?.tabBar.selectedItem = containerController?.tabBar.items![0] // so that when change to tab bar, the screen displayed is the first item in tab bar
            containerController?.swapFromViewController(containerController!.controller as! UIViewController, toViewController: containerController!.controllers[0])
               UserDefaults.standard.set("user", forKey: "cellType")
        revealViewController().pushFrontViewController(containerController,animated:true)
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                UserDefaults.standard.set("true", forKey: "searchResult")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let HomeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC")
                containerController?.swapFromViewController(containerController!.controller as! UIViewController, toViewController: HomeVC)
                
                containerController?.tabBar.selectedItem = nil
                
                revealViewController().pushFrontViewController(containerController,animated:true)
                containerController?.tabBar.isHidden = true
            } else {
                UserDefaults.standard.set("false", forKey: "searchResult")
                containerController?.tabBar.selectedItem = containerController?.tabBar.items![0] // so that when change to tab bar, the screen displayed is the first item in tab bar
                containerController?.swapFromViewController(containerController!.controller as! UIViewController, toViewController: containerController!.controllers[1])
                UserDefaults.standard.set("user", forKey: "cellType")
                revealViewController().pushFrontViewController(containerController,animated:true)
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let AboutMe = storyboard.instantiateViewController(withIdentifier: "AboutMe")
            containerController?.swapFromViewController(containerController!.controller as! UIViewController, toViewController: AboutMe)
            
            containerController?.tabBar.selectedItem = nil
            
            revealViewController().pushFrontViewController(containerController,animated:true)
            containerController?.tabBar.isHidden = true
        }
    }
}
