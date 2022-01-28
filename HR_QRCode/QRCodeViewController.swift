//
//  QRCodeViewController.swift
//  HR_QRCode
//
//  Created by heng liu on 2022/1/28.
//

import Foundation

class QRCodeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        qrImage.image = QRCodeGenerator.qrImage(for: "https://www.jianshu.com/u/e992b90359f7", imageSize: qrImage.frame.width, pointType: .round, color: .black, withRandomPercent: 10, withRandomColor: .orange, logoImage: UIImage(named: "avater"))
    }

    @IBOutlet weak var qrImage: UIImageView!
    
}
