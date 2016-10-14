//
//  LeftCell.swift
//  Weather
//
//  Created by Vincent on 16/10/8.
//  Copyright © 2016年 com.vincent.study. All rights reserved.
//

import UIKit

class LeftCell: UITableViewCell {

    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherBgView: UIView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherStateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        //设置背景颜色
        self.backgroundColor = ContentsInfo.backgroundColor
        
        // 设置选中样式
        self.selectionStyle = .none
        
        // 设置圆角
        self.weatherBgView.layer.cornerRadius = 10
        self.weatherBgView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
