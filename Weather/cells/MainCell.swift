//
//  MainCell.swift
//  Weather
//
//  Created by Vincent on 16/10/9.
//  Copyright © 2016年 com.vincent.study. All rights reserved.
//

import UIKit

class MainCell: UITableViewCell {

    @IBOutlet weak var weatherStateImageView: UIImageView!
    
    @IBOutlet weak var animationImageView: UIImageView!
    
    @IBOutlet weak var weatherTypeImageView: UIImageView!
    @IBOutlet weak var weatherTypeLabel: UILabel!
    
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    
    @IBOutlet weak var scopeTemperatureLabel: UILabel!
    
    @IBOutlet weak var windImageView: UIImageView!
    
    @IBOutlet weak var windLabel: UILabel!
    
    @IBOutlet weak var humidityImageView: UIImageView!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
