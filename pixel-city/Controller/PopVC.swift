//
//  PopVC.swift
//  pixel-city
//
//  Created by Raju Dhumne on 11/01/18.
//  Copyright © 2018 Raju Dhumne. All rights reserved.
//

import UIKit

class PopVC: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var popUpImageView: UIImageView!
    var passedImage:UIImage!
    func initData(forImage image:UIImage) {
        self.passedImage = image
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpImageView.image = passedImage
        addDoubleTap()
    }
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasRemoved))
    doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
    view.addGestureRecognizer(doubleTap)
    }
    
   @objc func screenWasRemoved() {
        dismiss(animated: true, completion: nil)
    }
  

}
