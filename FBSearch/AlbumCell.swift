//
//  AlbumCell.swift
//  FBSearch
//
//  Created by Savoki Song on 4/20/17.
//  Copyright © 2017 Yingzhao Song. All rights reserved.
//

import UIKit

class AlbumCell: UITableViewCell {

    @IBOutlet weak var albumName: UILabel!
    
    @IBOutlet weak var image1st: UIImageView!
    
    @IBOutlet weak var image2rd: UIImageView!
    
    class var expendedHeight: CGFloat { get {return 600} }
    class var defaultHeight: CGFloat { get {return 56 } }
    var isFrameAdded = false
    
    func checkHeight() {
      image1st.isHidden = (frame.size.height < AlbumCell.expendedHeight)
      image2rd.isHidden = (frame.size.height < AlbumCell.expendedHeight)
    }
    
    func watchFrameChanges() {
        if !isFrameAdded {
            addObserver(self, forKeyPath: "frame", options: .new, context: nil)
            checkHeight()
            isFrameAdded = true
        }
    }
    
    func ignoreFrameChanges() {
        if !isFrameAdded {
            removeObserver(self, forKeyPath: "frame")
            isFrameAdded = false
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: "frame")  //do not miss this
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
