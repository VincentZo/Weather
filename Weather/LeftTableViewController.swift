//
//  LeftTableViewController.swift
//  Weather
//
//  Created by Vincent on 16/10/1.
//  Copyright © 2016年 com.vincent.study. All rights reserved.
//

import UIKit
import SwiftyJSON
class LeftTableViewController: UITableViewController{

    var dataSource = [Weather]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = ContentsInfo.backgroundColor
        self.configSubviews()
        
        // 在通知中心注册通知,获取网络请求的数据
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name(rawValue: ContentsInfo.leftNotificationIndentifier), object: nil)
    }

    // 处理通知的方法,获取通知传递的数据
    func refreshData(sender:NSNotification){
        let array = sender.userInfo!["data"] as! [JSON]
        //print("\(array)_____\(type(of:array))")
        if self.dataSource.count > 0 {
            self.dataSource.removeAll()
        }
        // 遍历数组,添加到数据源中
        for item in array{
            let dic = item.dictionaryObject
            let wea = Weather.init(dictionary: dic!)
            self.dataSource.append(wea)
        }
        self.tableView.reloadData()
    }
    
    // MARK: 配置子视图属性
    func configSubviews(){
        // 设置代理和数据源
        // 继承了UITableViewController,不用设置代理和数据源
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
        
        // 注册 nib
        let nib = UINib.init(nibName:"LeftCell", bundle: Bundle.main)
        self.tableView.register(nib, forCellReuseIdentifier: ContentsInfo.leftCellIndentifier)
        
        // 设置背景颜色
        self.tableView.backgroundColor = ContentsInfo.backgroundColor
        
        // 设置分隔条
        self.tableView.separatorStyle = .none
        
        // 设置行高
        self.tableView.rowHeight = 122
    }
    
    // MARK: - Table view data source
    // numberOfSections方法说明
    // 1. 覆写了numberOfSections方法时,返回的 section 数量必须大于0,否则不能显示 cell
    // 2. 不覆写numberOfSections方法时,可以直接显示出 cell
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContentsInfo.leftCellIndentifier, for: indexPath) as! LeftCell
        
        let weather = self.dataSource[indexPath.row]
        
        // 使用通知获取的网络请求数据更新 tableview
        cell.dayLabel.text = Tool.switchWeekday(weekDay: weather.week!)
        cell.dateLabel.text = Tool.switchDate(dateString: weather.days!)
        cell.temperatureLabel.text = "\(weather.temp_low!)~\(weather.temp_high!)°"
        cell.weatherStateLabel.text = weather.weather!
        cell.weatherBgView.backgroundColor = Tool.getColorWithWeatherType(weather.weather!)
        if indexPath.row == 0{
            cell.dayLabel.text = "今天"
        }
        if indexPath.row == 1{
            cell.dayLabel.text = "明天"
        }
        
        return cell
    }
    
}











