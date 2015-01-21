//
//  SettingViewController.swift
//  FlashlightDemo
//
//  Created by kelei on 14/12/14.
//  Copyright (c) 2014年 kelei. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.canDisplayBannerAds = true
    }
    @IBAction func exitClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func deleteAdClick(sender: AnyObject) {
    }
    @IBAction func showNewAppsClick(sender: AnyObject) {
        let alert = UIAlertView(title: "未实现", message: nil, delegate: nil, cancelButtonTitle: "好")
        alert.show()
    }
    @IBAction func shareAPPClick(sender: AnyObject) {
        var activityItems = [AnyObject]()
        // 文字
        activityItems += ["这个手电筒应用不错哟！～"]
        // 截图
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let vc = appDelegate?.window?.rootViewController as? ViewController {
            activityItems += [vc.getViewScreenshot()]
        }
        
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.presentViewController(activityController, animated: true, completion: nil)
    }
    @IBAction func contactUsClick(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            if let url = NSURL(string: "mailto:543333414@qq.com") {
                UIApplication.sharedApplication().openURL(url)
            }
        } else {
            let alert = UIAlertView(title: "无邮件帐户", message: "请设置邮件帐户来发送电子邮件", delegate: nil, cancelButtonTitle: "好")
            alert.show()
        }
    }
    @IBAction func evaluationOfAPPClick(sender: AnyObject) {
        let alert = UIAlertView(title: "未实现", message: nil, delegate: nil, cancelButtonTitle: "好")
        alert.show()
    }
}
