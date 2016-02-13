//
//  FlashlightControl.swift
//  FlashlightDemo
//
//  Created by kelei on 14/12/9.
//  Copyright (c) 2014年 kelei. All rights reserved.
//

import Foundation
import AVFoundation

// 闪光模式
enum FlashlightControlGlitterMode: Int {
    case None       // 无闪光
    case Frequency  // 固定频率模式
    case SOS        // SOS模式（三短三长三短）
}

class FlashlightControl: NSObject {
    // 亮度0.01-1
    let BrightnessMinValue: Float = 0.01
    let BrightnessMaxValue: Float = 1.0
    var brightness: Float = 1.0 {
        didSet {
            if self.on && (self.glitterMode == .None) {
                self.myOn()
            }
        }
    }
    // 闪光频率10-60
    let GlitterFrequencyMinValue: Float = 2
    let GlitterFrequencyMaxValue: Float = 10
    var glitterFrequency: Int = 5 {
        didSet {
            if (self.glitterTimer != nil) && (self.glitterTimer!.timeInterval == self.glitterTimerInterval) {
                return
            }
            if self.on && (self.glitterMode == .Frequency) {
                self.startGlitterMode()
            }
        }
    }
    // 闪光模式
    var glitterMode: FlashlightControlGlitterMode = .None {
        didSet {
            if self.on {
                self.glitterMode == .Frequency  ? self.startGlitterMode()   : self.stopGlitterMode()
                self.glitterMode == .SOS        ? self.startSOSMode()       : self.stopSOSMode()
                self.glitterMode == .None       ? self.myOn()               : ()
            }
        }
    }
    //  手电开关状态
    var on: Bool = false {
        didSet {
            switch self.glitterMode {
            case .Frequency:
                self.on ? self.startGlitterMode() : self.stopGlitterMode()
            case .SOS:
                self.on ? self.startSOSMode() : self.stopSOSMode()
            default:
                self.on ? self.myOn() : self.myOff()
            }
        }
    }
    
    
    private lazy var device: AVCaptureDevice? = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    private var glitterTimerInterval: Double {
        return 1.0 / Double(self.glitterFrequency)
    }
    private var glitterTimer: NSTimer? = nil
    private var sosTimer: NSTimer? = nil
    deinit {
        self.glitterTimer?.invalidate()
        self.glitterTimer = nil
        self.sosTimer?.invalidate()
        self.sosTimer = nil
    }
    
    // 开
    private func myOn() {
        if (self.device != nil) && (self.device!.hasTorch) {
            try! self.device?.lockForConfiguration()
            try! self.device?.setTorchModeOnWithLevel(self.brightness)
            self.device?.unlockForConfiguration()
        }
    }
    // 关
    private func myOff() {
        try! self.device?.lockForConfiguration()
        if (self.device != nil) && (self.device!.torchMode == .On) {
            self.device?.torchMode = .Off
        }
        self.device?.unlockForConfiguration()
    }
    // 开启SOS模式
    private var sosNo: Int = 1
    private func startSOSMode() {
        self.stopSOSMode()
        self.sosNo = 1
        self.sosTimer = NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "sosOnTimer:", userInfo: nil, repeats: false)
    }
    @objc private func sosOnTimer(timer: NSTimer) {
        var ti: NSTimeInterval
        switch self.sosNo {
        case 4...6:
            ti = 1.0 / 2
        default://1...3, 7...9
            ti = 1.0 / 8
        }
        ++self.sosNo
        self.myOn()
        NSThread.sleepForTimeInterval(ti)
        self.myOff()
        
        if self.sosNo > 9 {
            self.sosNo = 1
            ti = 2
        } else {
            ti = 1.0 / 2
        }
        
        self.sosTimer = NSTimer.scheduledTimerWithTimeInterval(ti, target: self, selector: "sosOnTimer:", userInfo: nil, repeats: false)
    }
    private func stopSOSMode() {
        self.sosTimer?.invalidate()
        self.sosTimer = nil
    }
    // 开启闪光模式
    private func startGlitterMode() {
        self.stopGlitterMode()
        self.glitterTimer = NSTimer.scheduledTimerWithTimeInterval(self.glitterTimerInterval, target: self, selector: "glitterOnTimer:", userInfo: nil, repeats: true)
    }
    @objc private func glitterOnTimer(timer: NSTimer) {
        self.myOn()
        NSThread.sleepForTimeInterval(1.0 / 50)
        self.myOff()
    }
    private func stopGlitterMode() {
        self.glitterTimer?.invalidate()
        self.glitterTimer = nil
    }
}
