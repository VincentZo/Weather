//
//  RightTableViewController.swift
//  Weather
//
//  Created by Vincent on 16/10/1.
//  Copyright © 2016年 com.vincent.study. All rights reserved.
//

import UIKit

class RightTableViewController: UITableViewController {

    // 第一个section的标题
    var sectionOneTitles = ["提醒","设置","支持"]
    var sectionOneImage = ["reminder","setting_right","contact"]
    // 查看历史,需要做本地存储
    var historyCitys = Tool.getCacheCitys()
    
    var rootViewController : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = ContentsInfo.backgroundColor
        self.configSubviews()
        // 注册通知
        self.configNotification()
    }

    // MARK: 设置子视图属性
    func configSubviews(){
        // 注册 cell nib
        let nib = UINib.init(nibName: "RightCell", bundle: Bundle.main)
        self.tableView.register(nib, forCellReuseIdentifier: ContentsInfo.rightCellIndentifier)
        // 设置背景颜色
        self.tableView.backgroundColor = ContentsInfo.backgroundColor
        // 设置分割线
        self.tableView.separatorStyle = .none
        // 设置行高
        self.tableView.rowHeight = 90
    }
    
    // MARK: - 实现 tableView 的代理方法

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 这里需要根据不同的 section 来返回不同的行数
        if section == 0{
            return 3
        }else{
            return 2 + self.historyCitys.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ContentsInfo.rightCellIndentifier, for: indexPath) as! RightCell
        cell.controller = self
        // 判断 section
        if indexPath.section == 0{
            cell.deleteImageView.isHidden = true
            cell.cityLabel.text = self.sectionOneTitles[indexPath.row]
            cell.locationImageView.image = UIImage.init(named: self.sectionOneImage[indexPath.row])
        }else{
            // 判断行
            if indexPath.row == 0 {
                cell.cityLabel.text = "添加"
                cell.deleteImageView.isHidden = true
                cell.locationImageView.image = UIImage.init(named: "addcity")
            }else if indexPath.row == 1{
                cell.cityLabel.text = "定位"
                cell.deleteImageView.isHidden = true
                cell.locationImageView.image = UIImage.init(named: "city")
            }else{
                cell.cityLabel.text = self.historyCitys[indexPath.row-2]
                cell.locationImageView.image = UIImage.init(named: "city")
                cell.deleteImageView.isHidden = false
                
            }
        }
        

        return cell
    }
   
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let label = UILabel.init(frame: CGRect.zero)
            return label
        }else{
            let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 30))
            label.text = "城市管理"
            label.textAlignment = .center
            label.backgroundColor = ContentsInfo.backgroundColor
            label.textColor = UIColor.white
            return label
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            if indexPath.row == 0{
                let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                let addCityController = storyBoard.instantiateViewController(withIdentifier: "addCityContoller") as! AddCityTableViewController
                self.rootViewController?.present(addCityController, animated: true, completion: { 
                    //print("显示添加城市控制器")
                })
            }else if indexPath.row == 1{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ContentsInfo.autoLocationNotificationIndentifier), object: nil, userInfo: nil)
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: ContentsInfo.selectCityCellNotificationIndentifier), object: nil, userInfo: ["city":self.historyCitys[indexPath.row - 2]])
                
            }
        }
    }
    
    // MARK: 注册通知获取城市及自动定位信息
    func configNotification(){
        // 自动定位
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name.init(rawValue: ContentsInfo.autoLocationNotificationIndentifier), object: nil)
        // 获取城市
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name.init(rawValue: ContentsInfo.selectCityCellNotificationIndentifier), object: nil)
        // 获取删除 cell 后的通知信息
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name.init(rawValue: ContentsInfo.deleteCacheCityNotificationIndentifier), object: nil)
    }
    
    // 接收到通知过后,更新数据源.重新加载 tableView
    func reloadTableView(){
        self.historyCitys = Tool.getCacheCitys()
        self.tableView.reloadData()
    }
    
}
















