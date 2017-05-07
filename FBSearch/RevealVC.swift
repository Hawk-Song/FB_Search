//
//  RevealVC.swift
//
//  Created by Savoki Song on 4/18/17.
//  Copyright © 2017 Patrick BODET. All rights reserved.
//

import UIKit

class RevealVC: SWRevealViewController, SWRevealViewControllerDelegate {
    
    var surfaceView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tapGestureRecognizer()
        self.panGestureRecognizer()
        self.rearViewRevealOverdraw = 0
        surfaceView = UIView(frame: UIScreen.main.bounds)
    }
    
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        if position == FrontViewPosition.right {
            self.frontViewController.view.isUserInteractionEnabled = false
            self.frontViewController.view.addSubview(surfaceView!)
        }
        else {
            self.frontViewController.view.isUserInteractionEnabled = true
            surfaceView!.removeFromSuperview()
        }
    }
}
