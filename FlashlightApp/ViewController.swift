//
//  ViewController.swift
//  FlashlightDemo
//
//  Created by kelei on 14/12/8.
//  Copyright (c) 2014年 kelei. All rights reserved.
//

import UIKit
import iAd

class ViewController: UIViewController {
    
    @IBOutlet weak var onOffButton: UIButton!
    @IBOutlet weak var glitterSwitchBackImg: UIImageView!
    @IBOutlet weak var glitterSwitchButton: UIButton!
    @IBOutlet weak var lockSwitchBackImg: UIImageView!
    @IBOutlet weak var lockSwitchButton: UIButton!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var frequencySlider: UISlider!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var sosButton: UIButton!
    
    @IBAction func onOffButtonClick(sender: AnyObject) {
        self.flashlightControl.on = !self.flashlightControl.on
        self.setOnOffButtonImageWithState(self.flashlightControl.on)
    }
    @IBAction func brightnessSliderValueChanged(sender: AnyObject) {
        self.flashlightControl.brightness = self.brightnessSlider.value
    }
    @IBAction func frequencySliderValueChanged(sender: AnyObject) {
        var value = Int(self.frequencySlider.value)
        self.flashlightControl.glitterFrequency = value
        self.setFrequencyLabelText(value)
    }
    @IBAction func glitterSwitchButtonClick(sender: AnyObject) {
        self.glitterOn = !self.glitterOn
        if self.glitterOn {
            self.flashlightControl.glitterMode = .Frequency
            self.sosOn = false
        } else {
            self.flashlightControl.glitterMode = .None
        }
    }
    @IBAction func lockSwitchButtonClick(sender: AnyObject) {
        self.lockOn = !self.lockOn
    }
    @IBAction func sosButtonClick(sender: AnyObject) {
        self.sosOn = !self.sosOn
        if self.sosOn {
            self.flashlightControl.glitterMode = .SOS
            self.glitterOn = false
        } else {
            self.flashlightControl.glitterMode = .None
        }
    }
    
    var glitterOn: Bool = false {
        didSet {
            let imgName = self.glitterOn ? "Glitter-on" : "Glitter-off"
            var center = self.glitterSwitchButton.center
            center.x = self.glitterOn
                ? self.glitterSwitchBackImg.frame.origin.x + self.glitterSwitchBackImg.frame.size.width - 10
                : self.glitterSwitchBackImg.frame.origin.x + 10
            self.glitterSwitchButton.setBackgroundImage(UIImage(named: imgName), forState: .Normal)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.glitterSwitchButton.center = center
            })
        }
    }
    var lockOn: Bool = false {
        didSet {
            self.glitterSwitchButton.enabled = self.lockOn
            self.brightnessSlider.enabled = self.lockOn
            self.frequencySlider.enabled = self.lockOn
            self.sosButton.enabled = self.lockOn
            
            let imgName = self.lockOn ? "Lock-on" : "Lock-off"
            var center = self.lockSwitchButton.center
            center.x = self.lockOn
                ? self.lockSwitchBackImg.frame.origin.x + self.lockSwitchBackImg.frame.size.width - 10
                : self.lockSwitchBackImg.frame.origin.x + 10
            self.lockSwitchButton.setBackgroundImage(UIImage(named: imgName), forState: .Normal)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.lockSwitchButton.center = center
            })
        }
    }
    var sosOn: Bool = false {
        didSet {
            let imgName = self.sosOn ? "Alarm-on" : "Alarm-off"
            self.sosButton.setBackgroundImage(UIImage(named: imgName), forState: .Normal)
        }
    }
    
    lazy var flashlightControl = FlashlightControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 屏幕常亮
        UIApplication.sharedApplication().idleTimerDisabled = true
        // 显示广告
        self.canDisplayBannerAds = true
        // 设置控件样式
        self.setContolerStyle()
        // 加载限制
        self.brightnessSlider.minimumValue = self.flashlightControl.BrightnessMinValue
        self.brightnessSlider.maximumValue = self.flashlightControl.BrightnessMaxValue
        self.frequencySlider.minimumValue = self.flashlightControl.GlitterFrequencyMinValue
        self.frequencySlider.maximumValue = self.flashlightControl.GlitterFrequencyMaxValue
        // 加载用户配置
        self.loadFlashlightControlData()
        // 显示用户配置
        self.setOnOffButtonImageWithState(self.flashlightControl.on)
        self.brightnessSlider.value = self.flashlightControl.brightness
        self.frequencySlider.value = Float(self.flashlightControl.glitterFrequency)
        self.setFrequencyLabelText(self.flashlightControl.glitterFrequency)
        self.glitterOn = self.flashlightControl.glitterMode == .Frequency
        self.sosOn = self.flashlightControl.glitterMode == .SOS
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleWillResignActive", name: UIApplicationWillResignActiveNotification, object: nil)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var center = self.lockSwitchButton.center
        center.x = self.lockOn
            ? self.lockSwitchBackImg.frame.origin.x + self.lockSwitchBackImg.frame.size.width - 10
            : self.lockSwitchBackImg.frame.origin.x + 10
        self.lockSwitchButton.center = center
        
    }

    
    func setFrequencyLabelText(frequencyValue: Int) {
        self.frequencyLabel.text = "\(frequencyValue)Hz"
    }
    
    // UI相关
    func setContolerStyle() {
        self.brightnessSlider.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * -0.5))
        self.brightnessSlider.maximumTrackTintColor = UIColor.clearColor()
        self.brightnessSlider.setThumbImage(UIImage(named: "Power-3"), forState: .Normal)
        self.brightnessSlider.setMinimumTrackImage(UIImage(named: "Power-2"), forState: .Normal)
        
        self.glitterSwitchButton.ex_removeAutoresizing()
        self.lockSwitchButton.ex_removeAutoresizing()
        self.glitterSwitchButton.frame.size = CGSizeMake(44, 44)
        self.lockSwitchButton.frame.size = CGSizeMake(44, 44)
        
        self.frequencySlider.maximumTrackTintColor = UIColor.clearColor()
        self.frequencySlider.setThumbImage(UIImage(named: "HZ-3"), forState: .Normal)
        self.frequencySlider.setMinimumTrackImage(UIImage(named: "HZ-2"), forState: .Normal)
        self.frequencySlider.setMaximumTrackImage(UIImage(named: "HZ-1"), forState: .Normal)
    }
    func setOnOffButtonImageWithState(on: Bool) {
        let img = on ? "Switch-on" : "Switch-off"
        self.onOffButton.setBackgroundImage(UIImage(named: img), forState: .Normal)
    }
    func getViewScreenshot() -> UIImage {
        return UIImage.imageFromView(self.view)
    }
    
    // 用户数据
    func loadFlashlightControlData() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let brightness = userDefaults.objectForKey("brightness") as? Float {
            self.flashlightControl.brightness = brightness
        }
        if let glitterFrequency = userDefaults.objectForKey("glitterFrequency") as? Int {
            self.flashlightControl.glitterFrequency = glitterFrequency
        }
        if let glitterRaw = userDefaults.objectForKey("glitterMode") as? Int {
            if let glitterMode = FlashlightControlGlitterMode(rawValue: glitterRaw) {
                self.flashlightControl.glitterMode = glitterMode
            }
        }
        if let on = userDefaults.objectForKey("on") as? Bool {
            self.flashlightControl.on = on
        }
        if let lockOn = userDefaults.objectForKey("lockOn") as? Bool {
            self.lockOn = lockOn
        } else {
            self.lockOn = true
        }
    }
    func saveFlashlightControlData() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setFloat(  self.flashlightControl.brightness,          forKey: "brightness")
        userDefaults.setInteger(self.flashlightControl.glitterFrequency,    forKey: "glitterFrequency")
        userDefaults.setInteger(self.flashlightControl.glitterMode.rawValue,forKey: "glitterMode")
        userDefaults.setBool(   self.flashlightControl.on,                  forKey: "on")
        userDefaults.setBool(   self.lockOn,                                forKey: "lockOn")
        userDefaults.synchronize()
    }
    
    // 消息处理
    func handleDidBecomeActive() {
        self.loadFlashlightControlData()
    }
    func handleWillResignActive() {
        self.saveFlashlightControlData()
        self.flashlightControl.on = false
    }
}


extension UIView {
    func ex_removeAutoresizing() {
        let superview = self.superview
        self.removeFromSuperview()
        //self.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.sizeToFit()
        superview?.addSubview(self)
    }
}
extension UIImage {
    class func imageFromView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, view.layer.contentsScale);
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

