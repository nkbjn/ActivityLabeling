//
//  ActivityCollectionViewCell.swift
//  ActivityLabeling
//
//  Created by Wataru Sasaki on 2018/02/15.
//  Copyright © 2018年 Wataru Sasaki. All rights reserved.
//

import UIKit
import ChameleonFramework

class ActivityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.tintColor = UIColor.white
        
        self.iconView.layer.cornerRadius = 5
        self.iconView.layer.masksToBounds = true
        self.iconView.backgroundColor = UIColor.flatBlack
        
    }
    
}
