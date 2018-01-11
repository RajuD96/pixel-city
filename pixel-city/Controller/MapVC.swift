//
//  ViewController.swift
//  pixel-city
//
//  Created by Raju Dhumne on 09/01/18.
//  Copyright © 2018 Raju Dhumne. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController,UIGestureRecognizerDelegate{
    
    
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let regionRadius:Double = 1000
    let authorizationStatus = CLLocationManager.authorizationStatus()
    var spinner:UIActivityIndicatorView?
    var progressLabel:UILabel?
    var imageUrlsArry = [String]()
    var imageArry = [UIImage]()
    var screenSize = UIScreen.main.bounds
    var collectionView:UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.mapView.showsUserLocation = true
        configureLocationService()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        registerForPreviewing(with: self, sourceView: collectionView!)
        pullUpView.addSubview(collectionView!)
        addDoubleTap()
        addSwipe()
    }
    
        func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action:#selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
        func animateViewUp(){
        pullUpViewHeightConstraint.constant = 300
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
    }
    
    @objc func animateViewDown() {
        cancelAllSession()
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)!/2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
        
        
    }
    func removeSpinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    func removeProgressLabel() {
        if progressLabel != nil{
            progressLabel?.removeFromSuperview()
        }
    }
    
    func addProgressLabel(){
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 125 , y: 175, width: 250, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLabel?.textAlignment = .center
        collectionView?.addSubview(progressLabel!)
    }
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }

    @IBAction func centerMapBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
}
extension MapVC: MKMapViewDelegate {
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else{return}
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender:UITapGestureRecognizer) {
        removePin()
        removeSpinner()
        removeProgressLabel()
        cancelAllSession()
        imageUrlsArry = []
        imageArry = []
        collectionView?.reloadData()
    
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLabel()
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        fetchUrls(forAnnotation: annotation) { (finished) in
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLabel()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func fetchUrls(forAnnotation annotation:DroppablePin,handler: @escaping (_ status:Bool)-> ()) {
       
        
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, addNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
            let photos = json["photos"] as! Dictionary<String, AnyObject>
            let photoArry = photos["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photoArry {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlsArry.append(postUrl)
            }
            handler(true)
        }
    }
    func retrieveImages(handler:@escaping (_ status:Bool)->()) {
    
        
        for url in imageUrlsArry {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else {return}
                self.imageArry.append(image)
                self.progressLabel?.text = "\(self.imageArry.count)/40 Images Downloading"
                if self.imageArry.count == self.imageUrlsArry.count {
                    handler(true)
                }
            })
        }
    }
    
    func cancelAllSession() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
        
        
    }
    
    
}
extension MapVC: CLLocationManagerDelegate{
    func configureLocationService() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }else {
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
}
extension MapVC: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return UICollectionViewCell()}
        let indexFromImage = imageArry[indexPath.row]
        let imageView = UIImageView(image: indexFromImage)
        cell.addSubview(imageView)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArry.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       guard  let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(forImage: imageArry[indexPath.row])
        present(popVC, animated: true, completion:nil)
    }
}

extension MapVC:UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else {return nil}
        
        guard let popVc = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return nil}
        popVc.initData(forImage: imageArry[indexPath.row])
        previewingContext.sourceRect = cell.contentView.frame
        return popVc
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: nil)
    }
    
}




