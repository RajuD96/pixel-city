//
//  ViewController.swift
//  pixel-city
//
//  Created by Raju Dhumne on 09/01/18.
//  Copyright © 2018 Raju Dhumne. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
       mapView.delegate = self
    }

    @IBAction func centerMapBtnPressed(_ sender: Any) {
    }
}
extension MapVC: MKMapViewDelegate {
    
}

