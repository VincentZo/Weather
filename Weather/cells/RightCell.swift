//
//  RightCell.swift
//  Weather
//
//  Created by Vincent on 16/10/8.
//  Copyright © 2016年 com.vincent.study. All rights reserved.
//

import UIKit

class RightCell: UITableViewCell {

    @IBOutlet weak var locationImageView: UIImageView!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var deleteImageView: UIImageView!
    
    var controller : UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = ContentsInfo.backgroundColor
        self.selectionStyle = .none
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(delete(sender:)))
        self.deleteImageView.isUserInteractionEnabled = true
        self.deleteImageView.addGestureRecognizer(tap)
    }
    // 实现 delete 的方法
    func delete(sender : UITapGestureRecognizer){
        let alertController = UIAlertController.init(title: "提示", message: "确定删除该城市记录?", preferredStyle: UIAlertControllerStyle.alert)
        // 添加 action
        let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel) { (alertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        // 添加 action
        let okAction = UIAlertAction.init(title: "确定", style: UIAlertActionStyle.default) { (alertAction) in
            let result = Tool.deleteCityCache(city: self.cityLabel.text!)
            // 删除成功后发送通知
            if result {
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: ContentsInfo.deleteCacheCityNotificationIndentifier), object: nil, userInfo: nil)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        // 弹出 alert 对话框
        self.controller?.present(alertController, animated: true, completion: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 实现手势方法,处理 cell 的点击样式
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.backgroundColor = UIColor.gray
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.backgroundColor = ContentsInfo.backgroundColor
    }
}




