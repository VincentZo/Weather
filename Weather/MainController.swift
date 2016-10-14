//
//  MainController.swift
//  Weather
//
//  Created by Vincent on 16/10/1.
//  Copyright © 2016年 com.vincent.study. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON
import CoreLocation
// 如果是使用 cocoapods 进行添加的第三方 Objective_C SDK, 可以不在桥接头文件中声明头文件,而在swift 文件中直接 import 即可使用
import MBProgressHUD
class MainController: UIViewController,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource {

    var location : CLLocation? // 地图定位信息
    var locationManager : CLLocationManager? // 管理定位信息
    var geoCoder : CLGeocoder? // 地理位置反编码
    
    var tableView : UITableView?
    
    var currentWeather : Dictionary<String,Any>? // 保存当天的天气信息
    var localCity : String? // 保存定位的城市信息
    var hub : MBProgressHUD?
    var currentCity : String? // 当前显示天气的城市
    
    var rootController : UIViewController?
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置为默认的背景颜色
        self.view.backgroundColor = ContentsInfo.defaultBackgroundColor
        // 设置导航栏颜色
        self.navigationController?.navigationBar.tintColor = UIColor.white
        // 初始化属性
        self.initProperty()
        self.initAndConfigTableView()
        
        // 获取 userdefaults 中缓存的上次定位的城市信息
        let cityCache = UserDefaults.standard.value(forKey: ContentsInfo.userDefaultsCityCache)
        
        // 打开主界面,网络请求和定位之前的动画效果
        self.hub = MBProgressHUD.showAdded(to: self.view, animated: true)
        if cityCache == nil{
            self.hub?.label.text = "定位中..."
            // 开启定位
            self.startLocation()
        }else{
            self.localCity = cityCache as? String
            self.currentCity = cityCache as? String
            self.requestNetWork(city: self.currentCity!)
        }
        
        // 在通知中心注册接收方法
        self.configNotification()
        
    }

    // MARK: 初始化属性
    func initProperty(){
        self.location = CLLocation.init()
        self.locationManager = CLLocationManager.init()
        self.geoCoder = CLGeocoder.init()
    }
    
    // MARK: 初始化并设置 tableView
    func initAndConfigTableView(){
        // 初始化
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: 44, width: self.view.frame.size.width, height: self.view.frame.size.height), style: .plain)
        // 设置代理和数据源
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        // 注册 cell nib文件
        let nib = UINib.init(nibName: "MainCell", bundle: Bundle.main)
        self.tableView?.register(nib, forCellReuseIdentifier: ContentsInfo.mainCellIndentifier)
        // 设置样式
        self.tableView?.separatorStyle = .none
        self.tableView?.rowHeight = self.view.frame.height
        self.tableView?.showsVerticalScrollIndicator = false
        // 添加到 view
        self.view.addSubview(self.tableView!)
        
        // 使用 MJRefresh框架添加刷新操作
        self.tableView?.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { 
            self.requestNetWork(city: self.currentCity!)
        })
        
        // 隐藏 tableView
        self.tableView?.isHidden = true
        
        // 取消 scrollView 自动进行坐标转换的功能
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    
    // MARK: 实现 tableView 的代理方法
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView!.dequeueReusableCell(withIdentifier: ContentsInfo.mainCellIndentifier, for: indexPath) as! MainCell
        // 设置 cell 的样式
        if self.currentWeather != nil{
            
            cell.weatherStateImageView.image = Tool.getImageWithWeather(weatherInfo: self.currentWeather!)
            cell.weatherTypeImageView.image = Tool.getImageWithWeatherType(weatherType: self.currentWeather!["weather_curr"] as! String)
            cell.weatherTypeLabel.text = self.currentWeather!["weather_curr"] as? String
            cell.currentTemperatureLabel.text = self.currentWeather!["temp_curr"] as? String
            cell.scopeTemperatureLabel.text = "\(self.currentWeather!["temp_low"] as! String)~\(self.currentWeather!["temp_high"] as! String)°"
            cell.windLabel.text = "\(self.currentWeather!["wind"] as!String)\(self.currentWeather!["winp"] as!String)"
            cell.humidityLabel.text = self.currentWeather!["humidity"] as? String
        }
        return cell
    }
    
    // MARK:开启定位
    func startLocation(){
        // 设置locationManager 代理
        self.locationManager!.delegate = self
       
        // 设置定位精确度
        self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        
        // 设置定位更新距离
        self.locationManager?.distanceFilter = 1000
        
        // 针对不同的设备开启定位功能,设置定位功能开启的场景(后台或前台)
        if UIDevice.current.systemVersion >= "8.0.0" {
            self.locationManager!.requestWhenInUseAuthorization()
        }else{
            self.locationManager!.requestAlwaysAuthorization()
        }
        
        // 判断当前是否支持定位功能,再开启定位
        if CLLocationManager.locationServicesEnabled(){
            self.locationManager?.startUpdatingLocation()
        }
    }
    
    // MARK: 实现定位的代理方法
    // 定位成功的代理方法
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            let locationInfo = locations.last
            // 通过定位信息 location 获取 城市 等信息的反编码方法
            self.geoCoder?.reverseGeocodeLocation(locationInfo!, completionHandler: { (placemarks, error) in
                if placemarks!.count > 0{
                    let placeMark = placemarks!.last
                    let city = placeMark!.locality
                    if city!.contains("市"){
                        self.localCity = city?.substring(to: (city?.characters.index(of: "市"))!)
                        self.currentCity = self.localCity!
                        //print("\(self.localCity)")
                    }
                    self.hub?.label.text = "定位成功,正在加载天气信息..."
                    // 插入城市历史缓存文件
                    let _ = Tool.insertCityCache(city: self.localCity!)
                    // 将上次定位的城市保存到 userdefaults 中
                    UserDefaults.standard.set(self.localCity!, forKey: ContentsInfo.userDefaultsCityCache)
                    self.requestNetWork(city: self.localCity!)
                }
            })
        }
    }
    // 定位失败的代理方法,定位失败后设置城市为北京
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("定位失败:\(error)")
        self.hub?.label.text = "定位失败,请打开定位功能!"
        self.hub?.isHidden = true
        self.requestNetWork(city: "北京")
    }
    
    
    // MARK: 设置导航栏 barItem 样式
    func layoutBarItemToNavigationBar(_ date:String , weekDay:String , city:String){
        
        // 添加左边的 barItem
        let dateBarItem = UIBarButtonItem.init(image: UIImage.init(named: "category_hover"), style: .plain, target: self, action: #selector(chooseDate))
        let weekDayBarItem = UIBarButtonItem.init(title: "\(date)/\(weekDay)", style: .plain, target: self, action: #selector(chooseDate))
        // 使用navigationItem属性来获取 barItem, 统一管理 barItem
        self.navigationItem.leftBarButtonItems = [dateBarItem,weekDayBarItem]
        
        // 添加右边的 barItem
        let settingBarItem = UIBarButtonItem.init(image: UIImage.init(named: "settings_hover"), style: .plain, target: self, action: #selector(setting))
        let cityBarItem = UIBarButtonItem.init(title: city, style: .plain, target: nil, action: nil)
        let shareBarItem = UIBarButtonItem.init(image: UIImage.init(named: "share_small_hover"), style: .plain, target: self, action: #selector(share))
        self.navigationItem.rightBarButtonItems = [settingBarItem,cityBarItem,shareBarItem]
    }
    
    // MARK: 选择日期
    func chooseDate(_ sender : UIBarButtonItem){
        
    }
    
    // MARK: 设置
    func setting(_ sender : UIBarButtonItem){
        
    }
    
    // MARK: 分享
    func share(_ sender : UIBarButtonItem){
         self.initShareView()
    }
    
    // 处理网络请求
    func requestNetWork(city : String){
        // 获取未来7天的天气信息
        // 必须对请求的 url 做可用检查,去除中文特殊符号,进行重编码
        let url = "http://api.k780.com:88/?app=weather.future&weaid=\(city)&&appkey=10003&sign=b59bc3ef6191eb9f747dd4e83c99f2a4&format=json".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        // AlamoFire 请求 JSON数据
        Alamofire.request(url!).responseJSON { (response) in
            // 使用 SwiftyJSON 进行解析
            // 获取 JSON 对象
            let json = JSON.init(data: response.data!)
            // 获取 swift Array对象
            let array = json["result"].arrayValue
            // 获取 swift Dictionary 对象
            //let dic = array[0].dictionaryObject
            //let weather = Weather.init(dictionary: dic!)
            //  iOS10 swift3.0 中GCD 的使用
            DispatchQueue.main.async {
                // 发送通知
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: ContentsInfo.leftNotificationIndentifier), object: nil, userInfo: ["data":array])
            }
        }
        
        // 获取当天的天气信息
        let current_url = "http://api.k780.com:88/?app=weather.today&weaid=\(city)&&appkey=10003&sign=b59bc3ef6191eb9f747dd4e83c99f2a4&format=json".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        Alamofire.request(current_url!).responseJSON { (response) in
            let json = JSON.init(data: response.data!)
            self.currentWeather = json["result"].dictionaryObject
            // 调用主队列更新 UI
            DispatchQueue.main.async {
                //print("\(self.currentWeather)")
                // 布局导航栏
                self.layoutBarItemToNavigationBar(Tool.obtainDateString(Date()), weekDay: Tool.obtainWeekDay(Date()), city: city)
                // 更新主界面 UI
                self.layoutUIAfterNetWorkInMainQueue()
                self.tableView?.reloadData()
                self.hub?.hide(animated: true)
            }
        }

    }
    // 更新主界面 UI 代码
    func layoutUIAfterNetWorkInMainQueue(){
        // 更新界面 UI
        self.view.backgroundColor = Tool.getColorWithWeatherType(self.currentWeather!["weather"] as! String)
        self.tableView?.backgroundColor = Tool.getColorWithWeatherType(self.currentWeather!["weather"] as! String)
        self.navigationController?.navigationBar.backgroundColor = Tool.getColorWithWeatherType(self.currentWeather!["weather"] as! String)
        let indexPath = IndexPath.init(row: 0, section: 0)
        let cell = self.tableView!.cellForRow(at: indexPath) as! MainCell
        cell.contentView.backgroundColor = Tool.getColorWithWeatherType(self.currentWeather!["weather"] as! String)
        // 显示 tableView
        self.tableView?.isHidden = false
        // 结束刷新
        self.tableView?.mj_header.endRefreshing()

    }
    
    // MARK: 注册通知获取城市及自动定位信息
    func configNotification(){
        // 自动定位
        NotificationCenter.default.addObserver(self, selector: #selector(autoLocation), name: NSNotification.Name.init(rawValue: ContentsInfo.autoLocationNotificationIndentifier), object: nil)
        // 获取城市
        NotificationCenter.default.addObserver(self, selector: #selector(selectCity), name: NSNotification.Name.init(rawValue: ContentsInfo.selectCityCellNotificationIndentifier), object: nil)
    }
    
    // 自动定位
    func autoLocation(sender : Notification){
        self.startLocation()
    }
    // 根据城市进行请求天气信息
    func selectCity(sender : Notification){
        let city = sender.userInfo?["city"] as! String
        // 插入城市历史缓存文件
       let _ = Tool.insertCityCache(city: city)
        self.currentCity = city
        self.requestNetWork(city: city)
    }
    
    // MARK: 添加分享视图
    /*
        实现步骤:
            1.在各大社交平台注册开发者账号    
            2.在开放平台中配置 App bundleID 名称等信息, 获取 Appkey 和授权码
            3.在 Mob.com 网站上查询第三方平台分享的 SDK, 在项目中引入 SDK,
            4.根据 Mob.com 上的教程,实现第三方平台登录和分享功能
     
     */
    // 4.在分享按钮方法中定制分享内容和分享类型
    func initShareView(){
        // 创建一个模态控制器
        let shareController = UIAlertController.init(title: "分享天气", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let sinaAction = UIAlertAction.init(title: "新浪微博", style: .default) { (action) in
            // 创建分享参数
            let shareParames = NSMutableDictionary()
            shareParames.ssdkSetupShareParams(byText: "分享功能",
                                              images : Tool.drawViewToImage(view: (self.navigationController?.view)!),
                                              url : NSURL(string:"http:// www.baidu.com") as URL!,
                                              title : "新项目测试",
                                              type : SSDKContentType.auto)
            
            //进行分享
            ShareSDK.share(SSDKPlatformType.typeSinaWeibo, parameters: shareParames) { (state : SSDKResponseState, nil, entity : SSDKContentEntity?, error :Error?) in
                
                switch state{
                    
                case SSDKResponseState.success: print("分享成功")
                case SSDKResponseState.fail:    print("授权失败,错误描述:\(error)")
                case SSDKResponseState.cancel:  print("操作取消")
                    
                default:
                    break
                }
                
            }
        }
        
        let QQAction = UIAlertAction.init(title: "QQ", style: UIAlertActionStyle.default) { (action) in
            // 创建分享参数
            let shareParames = NSMutableDictionary()
            shareParames.ssdkSetupShareParams(byText: "分享功能",
                                              images : Tool.drawViewToImage(view: (self.navigationController?.view)!),
                                              url : NSURL(string:"http:// www.baidu.com") as URL!,
                                              title : "新项目测试",
                                              type : SSDKContentType.auto)
            
            //进行分享
            ShareSDK.share(SSDKPlatformType.typeQQ, parameters: shareParames) { (state : SSDKResponseState, nil, entity : SSDKContentEntity?, error :Error?) in
                
                switch state{
                    
                case SSDKResponseState.success: print("分享成功")
                case SSDKResponseState.fail:    print("授权失败,错误描述:\(error)")
                case SSDKResponseState.cancel:  print("操作取消")
                    
                default:
                    break
                }
                
            }

        }
        let QQZoneAction = UIAlertAction.init(title: "QQ空间", style: UIAlertActionStyle.default) { (action) in
            // 创建分享参数
            let shareParames = NSMutableDictionary()
            shareParames.ssdkSetupShareParams(byText: "分享功能",
                                              images : Tool.drawViewToImage(view: (self.navigationController?.view)!),
                                              url : NSURL(string:"http:// www.baidu.com") as URL!,
                                              title : "新项目测试",
                                              type : SSDKContentType.image)
            
            //进行分享
            ShareSDK.share(SSDKPlatformType.subTypeQZone, parameters: shareParames) { (state : SSDKResponseState, nil, entity : SSDKContentEntity?, error :Error?) in
                
                switch state{
                    
                case SSDKResponseState.success: print("分享成功")
                case SSDKResponseState.fail:    print("授权失败,错误描述:\(error)")
                case SSDKResponseState.cancel:  print("操作取消")
                    
                default:
                    break
                }
                
            }

        }
        let wechatAction = UIAlertAction.init(title: "微信", style: UIAlertActionStyle.default) { (action) in
            
        }
        let wechatFriendAction = UIAlertAction.init(title: "朋友圈", style: UIAlertActionStyle.default) { (action) in
            
        }
        let facebookAction = UIAlertAction.init(title: "FaceBook", style: UIAlertActionStyle.default) { (action) in
            
        }
        let twitterAction = UIAlertAction.init(title: "Twitter", style: UIAlertActionStyle.default) { (action) in
            
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel) { (action) in
            shareController.dismiss(animated: true, completion: nil)
        }
        shareController.addAction(sinaAction)
        shareController.addAction(QQAction)
        shareController.addAction(QQZoneAction)
        shareController.addAction(wechatAction)
        shareController.addAction(wechatFriendAction)
        shareController.addAction(facebookAction)
        shareController.addAction(twitterAction)
        shareController.addAction(cancelAction)
        
        // 使用 rootController 弹出模态控制器
        self.rootController?.present(shareController, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



















