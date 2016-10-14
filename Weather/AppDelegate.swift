//
//  AppDelegate.swift
//  Weather
//
//  Created by Vincent on 16/10/1.
//  Copyright © 2016年 com.vincent.study. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // 设置(取消)导航栏的背景图片
        // UINavigationBar.appearance()方法可以返回当前应用的当前导航栏对象,可以进行样式修改
        let bar = UINavigationBar.appearance()
        bar.setBackgroundImage(UIImage.init(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        bar.shadowImage = UIImage.init()
        
        // 1.注册第三方分享
        ShareSDK.registerApp(ContentsInfo.share_AppKey, activePlatforms: [
                SSDKPlatformType.typeSinaWeibo.rawValue,SSDKPlatformType.typeQQ.rawValue
            ], onImport: { (platfrom) in
                // 判断分享的三分平台是什么类型,创建连接平台
                switch platfrom{
                case .typeQQ:
                     ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                case .typeSinaWeibo:
                    ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                    break
                default:
                    break
                }
            }) { (platformType, appInfoDictionary) in
                // 判断平台类型,注册已经申请好的 appID 和 KEY 等信息
                switch platformType{
                case .typeSinaWeibo:
                    appInfoDictionary?.ssdkSetupSinaWeibo(byAppKey: ContentsInfo.sina_AppKey, appSecret: ContentsInfo.sina_AppSecret, redirectUri: ContentsInfo.sina_OAuth_URL, authType: SSDKAuthTypeBoth)
                case .typeQQ:
                    appInfoDictionary?.ssdkSetupQQ(byAppId: ContentsInfo.qq_AppID, appKey: ContentsInfo.qq_AppKey, authType: SSDKAuthTypeBoth)
                default:
                    break
                }
        }
        
        //2.适配 iOS9 添加分享白名单
        //3.配置项目: info -> URL Types ->添加需要分享的平台,设置 appID(appKey),使用 QQ 需要将 appID(appKEY) 装换为大写的16进制,若没有8位,则向前补0
        
        return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


/* 第三方分享白名单 加入 plist 文件中
 <key>LSApplicationQueriesSchemes</key>
 <array>
 <string>wechat</string>
 <string>weixin</string>
 <string>sinaweibohd</string>
 <string>sinaweibo</string>
 <string>sinaweibosso</string>
 <string>weibosdk</string>
 <string>weibosdk2.5</string>
 <string>mqqapi</string>
 <string>mqq</string>
 <string>mqqOpensdkSSoLogin</string>
 <string>mqqconnect</string>
 <string>mqqopensdkdataline</string>
 <string>mqqopensdkgrouptribeshare</string>
 <string>mqqopensdkfriend</string>
 <string>mqqopensdkapi</string>
 <string>mqqopensdkapiV2</string>
 <string>mqqopensdkapiV3</string>
 <string>mqzoneopensdk</string>
 <string>wtloginmqq</string>
 <string>wtloginmqq2</string>
 <string>mqqwpa</string>
 <string>mqzone</string>
 <string>mqzonev2</string>
 <string>mqzoneshare</string>
 <string>wtloginqzone</string>
 <string>mqzonewx</string>
 <string>mqzoneopensdkapiV2</string>
 <string>mqzoneopensdkapi19</string>
 <string>mqzoneopensdkapi</string>
 <string>mqzoneopensdk</string>
 <string>alipay</string>
 <string>alipayshare</string>
 </array>

 */
