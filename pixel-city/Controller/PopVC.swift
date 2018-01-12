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
    @IBOutlet weak var imageTitle: UILabel!
    @IBOutlet weak var imageOwner: UILabel!
    
    var passedImage:UIImage!
    var imageTitles:String!
    func initData(image:UIImage,title:String) {
        self.passedImage = image
        self.imageTitles = title
        
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpImageView.image = passedImage
        imageTitle.text = imageTitles
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
