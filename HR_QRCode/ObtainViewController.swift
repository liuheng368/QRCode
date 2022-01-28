//
//  ObtainViewController.swift
//  HR_QRCode
//
//  Created by heng liu on 2022/1/28.
//

import Foundation
import UIKit


//demo中相机权限没有申请
class ObtainViewController: UIViewController {
    private lazy var obtain: XYPHQRCodeObtain = XYPHQRCodeObtain.obtainManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fromPhoto()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRCodeScan()
    }
    
    private func setupQRCodeScan() {
        let configure = XYPHQRCodeObtainConfigure.obtainConfigureManager()
        configure?.sampleBufferDelegate = true
        configure?.openLog = true
        configure?.rectOfInterest = CGRect(x: 0.05, y: 0.2, width: 0.7, height: 0.6)
        configure?.metadataObjectTypes =
        [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.code128]
        obtain.establishQRCodeObtainScan(with: self, configure: configure)
        
        // 扫描成功
        obtain.setBlockWithQRCodeObtainScanResult {[weak self] obtain, result in
            guard let self = self else { return }
            if let result = result {
                obtain?.stopRunning()
                print(result)
            }
        }
        
        // 光线强弱
        obtain.setBlockWithQRCodeObtainScanBrightness { _, brightness in
            if brightness < -1 {    // 光线差
                
            }
        }
    }
    
    private func fromPhoto() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] (granted:Bool) in
                self?.obtain.startRunningWith(before: nil, completion: nil)
            }
        case .authorized:
            self.obtain.startRunningWith(before: nil, completion: nil)
        default:
            break
        }
    }
}
