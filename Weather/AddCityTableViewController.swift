//
//  AddCityTableViewController.swift
//  Weather
//
//  Created by Vincent on 16/10/10.
//  Copyright © 2016年 com.vincent.study. All rights reserved.
//

import UIKit

class AddCityTableViewController: UITableViewController {

    var citys = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initCitys()
        self.configTableView()
        
    }
    
    // MARK:配置tableView
    func configTableView(){
        // 去除分割线
        self.tableView.separatorStyle = .none
        // 注册 cell
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "addCityCell")
        self.tableView.backgroundColor = ContentsInfo.backgroundColor
        self.tableView.rowHeight = 44
        
        // 定义头视图
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        headerView.backgroundColor = ContentsInfo.backgroundColor
        
        let searchTextField = UITextField.init(frame: CGRect.init(x: 20, y: 14, width: self.view.frame.size.width - 40, height: 30))
        searchTextField.backgroundColor = UIColor.white
        searchTextField.layer.cornerRadius = 15
        searchTextField.layer.masksToBounds = true
        searchTextField.leftView = UIImageView.init(image: UIImage.init(named: "search_b"))
        searchTextField.leftViewMode = .always
        searchTextField.placeholder = "请输入城市名称或者拼音..."
        headerView.addSubview(searchTextField)
        self.tableView.tableHeaderView = headerView
    }
    
    // MARK: 初始化数据源
    func initCitys(){
        let path = Bundle.main.path(forResource: "default-city", ofType: "plist")
        if path != nil{
            let array = NSArray.init(contentsOfFile: path!)
            for item in array!{
                let value = item as! String
                self.citys.append(value)
            }
        }
    }
    

   
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return self.citys.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCityCell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = ContentsInfo.backgroundColor
        //cell.selectionStyle = .none
        if indexPath.row == 0{
            cell.imageView?.image = UIImage.init(named: "city")!
            cell.textLabel?.text = "自动定位"
        }else{
            cell.imageView?.image = nil
            cell.textLabel?.text = self.citys[indexPath.row - 1]
        }
     
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ContentsInfo.autoLocationNotificationIndentifier), object: nil, userInfo: nil)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ContentsInfo.selectCityCellNotificationIndentifier), object: nil, userInfo: ["city":self.citys[indexPath.row - 1]])
        }
        // 点击 cell 退出控制器
        self.dismiss(animated: true) {
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 隐藏状态栏
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
