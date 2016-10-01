//
//  ViewController.swift
//  Weather
//
//  Created by Vincent on 16/10/1.
//  Copyright © 2016年 com.vincent.study. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // 创建主要交互界面的属性
    var mainController : UIViewController?
    var leftTableViewController : LeftTableViewController?
    var rightTableViewController : RightTableViewController?
    
    // 滑动缓冲
    let speed_buff:CGFloat = 0.5
    
    // 保存滑动的真实距离
    var pan_scope:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSubviews()
        self.configSubviews()
    }
    
    // 初始化属性
    func initSubviews(){
        // 将 mainController 嵌入到 UINavigationController 中,设置为根控制器
        let rootController = MainController()
        self.mainController = UINavigationController.init(rootViewController: rootController)
        self.leftTableViewController = LeftTableViewController()
        self.rightTableViewController = RightTableViewController()
    }
    
    // 配置子视图
    func configSubviews(){
        // 添加到 self.view 中
        self.view.addSubview(self.leftTableViewController!.view)
        self.view.addSubview(self.rightTableViewController!.view)
        self.view.addSubview(self.mainController!.view)
        
        self.leftTableViewController?.view.isHidden = true
        self.rightTableViewController?.view.isHidden = true
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(doPan))
        self.mainController?.view.isUserInteractionEnabled = true
        self.mainController?.view.addGestureRecognizer(pan)
        
    }
    
    // MARK: 实现滑动主界面的方法
    func doPan(sender:UIPanGestureRecognizer){
       // print("滑动屏幕...")
        // 直接获取 view 中点击的某一点的坐标
        let point = sender.translation(in: sender.view)
        
        // 滑动效果处理
        sender.view?.center = CGPoint(x: sender.view!.center.x + point.x * self.speed_buff, y: sender.view!.center.y)
        
        // 重新定位坐标
         sender.setTranslation(CGPoint(x:0,y:0), in: sender.view!)
        // 判断屏幕滑动的方向
        if sender.view!.frame.origin.x >= 0{
            self.rightTableViewController?.view.isHidden = true
            self.leftTableViewController?.view.isHidden = false
        }else{
            self.rightTableViewController?.view.isHidden = false
            self.leftTableViewController?.view.isHidden = true
        }
        
        // 不断累加滑动距离
        self.pan_scope = point.x * self.speed_buff + self.pan_scope
        
        // 判断是否滑动结束
        if sender.state == .ended{
            // 根据滑动距离判断,显示不同视图
            if self.pan_scope > UIScreen.main.bounds.size.width * CGFloat(0.5) * self.speed_buff{
                self.showLeft()
            }else if self.pan_scope < UIScreen.main.bounds.size.width * CGFloat(-0.5) * self.speed_buff{
                self.showRight()
            }else{
                self.showMain()
            }
            
            
        }
        
    }
    
    // 显示 mainController
    func showMain(){
        UIView.animate(withDuration: 0.2) {
            self.mainController?.view.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
        }
    }
    // 显示左边
    func showLeft(){
        UIView.animate(withDuration: 0.2) {
            self.mainController?.view.center = CGPoint.init(x: UIScreen.main.bounds.size.width * CGFloat(1.5) - CGFloat(60), y: UIScreen.main.bounds.size.height/2)
        }
    }
    // 显示右边
    func showRight(){
        UIView.animate(withDuration: 0.2) {
            self.mainController?.view.center = CGPoint.init(x: CGFloat(60) - UIScreen.main.bounds.size.width * CGFloat(0.5), y: UIScreen.main.bounds.size.height/2)
        }
    }

}












