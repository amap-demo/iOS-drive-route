//
//  RoutePathDetailTableViewCell.swift
//  Drive-Route-Demo
//
//  Created by eidan on 16/12/22.
//  Copyright © 2016年 autonavi. All rights reserved.
//

import UIKit

class RoutePathDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var bottomVerticalLine: UIView!
    
    @IBOutlet weak var topVerticalLine: UIView!
    
    @IBOutlet weak var actionImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
