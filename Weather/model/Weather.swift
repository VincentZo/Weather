//
//  Weather.swift
//  Weather
//
//  Created by Vincent on 16/10/9.
//  Copyright © 2016年 com.vincent.study. All rights reserved.
//

import UIKit

class Weather: NSObject {
    var weaid:String?
    var days:String?
    var week:String?
    var cityno:String?
    var citynm:String?
    var cityid:String?
    var temperature:String?
    var humidity:String?
    var weather:String?
    var weather_icon:String?
    var weather_icon1:String?
    var wind:String?
    var winp:String?
    var temp_high:String?
    var temp_low:String?
    var humi_high:String?
    var humi_low:String?
    var weatid:String?
    var weatid1:String?
    var windid:String?
    var winpid:String?
    init(dictionary : Dictionary<String,Any>) {
        super.init()
        self.setValuesForKeys(dictionary)
    }
}
