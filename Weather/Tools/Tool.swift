//
//  Tool.swift
//  Weather
//
//  Created by Vincent on 16/10/8.
//  Copyright © 2016年 com.vincent.study. All rights reserved.
//

import UIKit

// 城市历史信息缓存文件
let cityCacheFile = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/history_city.txt"
class Tool: NSObject {
    
    
    class func obtainDateString(_ date : Date)->String{
        let df = DateFormatter.init()
        df.locale = Locale.init(identifier: "ch")
        df.dateFormat = "MM.dd"
        let dateStr = df.string(from: date as Date)
        return dateStr
    }
   /*
    星期日：Sunday
    星期一：Monday
    星期二：Tuesday
    星期三：Wednesday
    星期四：Thursday
    星期五：Friday 
    星期六：Saturday
 */
    class func obtainWeekDay(_ date : Date)->String{
        let df = DateFormatter.init()
        df.locale = Locale.init(identifier: "ch")
        df.dateFormat = "EEEE"
        let dateStr = df.string(from: date as Date)
        switch dateStr {
        case "Sunday":
            return "星期日"
        case "Monday":
            return "星期一"
        case "Tuesday":
            return "星期二"
        case "Wednesday":
            return "星期三"
        case "Thursday":
            return "星期四"
        case "Friday":
            return "星期五"
        default:
            return "星期六"
        }
    }
    
    // MARK: 通过16进制数据获取颜色
    class func colorWithHexString (_ hex:String) -> UIColor {
        // 出去16进制数的空格和线条
        var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        // 出去16进制的前缀"#"
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substring(from: 1)
        }
        
        // 判断如果不是一个正确的16进制数,则返回灰色
        if (cString.characters.count != 6) {
            return UIColor.gray
        }
        
        // 截取16进制数的 rgb 字符串,依次为 r,g,b, 两个数据为一种颜色
        let rString = (cString as NSString).substring(to: 2)
        let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
        let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
        
        // 对应声明 rgb 的三个 C语言类型的无符号整数
        var r:CUnsignedInt = 0
        var g:CUnsignedInt = 0
        var b:CUnsignedInt = 0
        /*
         An NSScanner object interprets and converts the characters of an NSString object into number and string values
         Scanner类是处理字符串和数字相互转换的工具类,可以把字符串转换为数字表现形式
         */
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        let color = UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
        return color
    }
    // MARK: 根据天气类型来获取颜色
    class func getColorWithWeatherType(_ weather : String) -> UIColor{
        let path = Bundle.main.path(forResource: "weatherBG", ofType: "plist")
        if path != nil{
            let dictionary = NSDictionary.init(contentsOfFile: path!)
            
            for item in dictionary!.allKeys{
                let key = item as! String
                if key == weather{
                    return Tool.colorWithHexString((dictionary![key] as! String))
                }
            }
        }
        return UIColor.gray
    }
    
    // MARK: 返回固定格式的日期 MM/dd
    class func switchDate(dateString : String) -> String{
        // 将日期字符串转换为固定格式的日期
        let df = DateFormatter.init()
        df.locale = Locale.init(identifier: "ch")
        df.dateFormat = "YYYY-MM-dd"
        let date = df.date(from: dateString)
        
        // 转换日期格式为固定格式
        let newdf = DateFormatter.init()
        newdf.locale = Locale.init(identifier: "ch")
        newdf.dateFormat = "MM/dd"
        let result = newdf.string(from: date!)
        return result
    }
    
    // MARK: 将"星期几"转换为"周几"
    class func switchWeekday(weekDay: String) -> String{
        switch weekDay {
        case "星期一":
            return "周一"
        case "星期二":
            return "周二"
        case "星期三":
            return "周三"
        case "星期四":
            return "周四"
        case "星期五":
            return "周五"
        case "星期六":
            return "周六"
        default:
            return "周日"
        }
    }
    
    // MARK:获取天气类型的图片
    class func getImageWithWeatherType(weatherType : String) -> UIImage{
        // 获取 plist 文件
        let path = Bundle.main.path(forResource: "weatherImage", ofType: "plist")
        if path != nil {
            // 通过plist文件创建字典
            let dictionary = NSDictionary.init(contentsOfFile: path!)
            for item in dictionary!.allKeys{
                let key = item as! String
                if weatherType == key {
                    return UIImage.init(named: dictionary![key] as! String)!
                }
            }
        }
        
        return UIImage.init(named:"wycx_normal")!
    }
    
    // MARK:获取天气状态的图片:
    class func getImageWithWeather(weatherInfo: Dictionary<String,Any>) -> UIImage{
        // 判断高温天气
        if Int(weatherInfo["temp_curr"] as! String)! > 30{
            return UIImage.init(named: "jrgw_normal")!
        }
        // 判断风力
        if Int((weatherInfo["winp"] as! NSString).substring(to: 1))! > 7{
            return UIImage.init(named: "dflx_normal")!
        }
        
        // 否则解析 plist 文件进行返回
        let path = Bundle.main.path(forResource: "weatherMessage", ofType: "plist")
        if path != nil{
            let dictionary = NSDictionary.init(contentsOfFile: path!)
            for item in dictionary!.allKeys{
                let key = item as! String
                if weatherInfo["weather_curr"] as! String == key {
                    return UIImage.init(named: dictionary![key] as! String)!
                }
            }
        }
        return UIImage.init(named:"wycx_normal")!
    }
    
    // MARK: 读取城市的缓存信息
    class func getCacheCitys() -> [String]{
        let array = NSArray.init(contentsOfFile: cityCacheFile)
        if array == nil || array?.count == 0{
            return []
        }else{
            var citys = [String]()
            for item in array!{
                citys.append(item as! String)
            }
            return citys
        }
    }
    
    // MARK: 插入城市缓存信息
    class func insertCityCache(city : String)->Bool{
        // 获取数组
        var array = Tool.getCacheCitys()
        if array.contains(city){
            array.remove(at: array.index(of: city)!)
        }
        // 将最近的一个城市添加到第一个
        array.insert(city, at: 0)
        let citys = NSMutableArray()
        for item in array{
            citys.add(item)
        }
        return citys.write(toFile: cityCacheFile, atomically: true)
        
    }
    
    // MARK: 删除城市缓存信息
    class func deleteCityCache(city : String)->Bool{
        // 获取数组
        var array = Tool.getCacheCitys()
        if array.contains(city){
            array.remove(at: array.index(of: city)!)
        }
        return (array as NSArray).write(toFile: cityCacheFile, atomically: true)
    }
   
    // MARK: 将 view 转换为 image
    class func drawViewToImage(view : UIView) -> UIImage?{
        // 开始绘制,并设置绘制内容的大小
        UIGraphicsBeginImageContext(view.bounds.size)
        // 通过设置的绘制大小, 通过 view.layer 返回一个覆盖层
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        // 从当前绘制的上下文中获取绘制的image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // 结束图片绘制
        UIGraphicsEndImageContext()
        return image
    }
    
}


















