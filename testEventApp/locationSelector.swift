//
//  locationSelector.swift
//  testEventApp
//
//  Created by Carl Andreas Julsvoll on 01/10/16.
//  Copyright © 2016 CarlTesting. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FBSDKCoreKit

class locationSelector: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    //TODO: fix prepare for segue to inviteFriends
    
    @IBOutlet weak var mapPin: UIImageView!
    @IBOutlet var nextBtn: [UIButton]!
    @IBOutlet weak var addressBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var ref: DatabaseReference!
    
    var inCreationEvent: InCreationEvent?
    var weekday: String = ""
    var dateFromChooseDay: Date = Date()
    var hourMin: String = ""
    var titleFromPrevView: String = ""
    
    var locationManager: CLLocationManager?
    var address: String = ""
    var longi: Double = 0.0
    var lati: Double = 0.0
    var panGestureRecognizer: UIPanGestureRecognizer!

    
    // TODO: Make time and date get into this view as well
    
    override func viewDidLoad() {
        self.mapPin.alpha = 1
        super.viewDidLoad()
        self.mapView.delegate = self
        self.ref = Database.database().reference()

        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager!.startUpdatingLocation()
        } else {
            locationManager!.requestWhenInUseAuthorization()
        }
        self.mapView.showsUserLocation = true
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draggablePanGestureAction))
        self.view.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        let center = mapView.centerCoordinate
       
        let geoCoder = CLGeocoder()
        
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if (error != nil){
                
            } else {
                if let street = placemarks![0].addressDictionary?[AnyHashable("Name")] {
                    self.addressBtn.setTitle(String(describing: street), for: UIControlState.normal)
                    self.address = String(describing: street)
                    
                }
            }
            })
        
        
        self.longi = center.longitude
        self.lati = center.latitude
        

        
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print(error?.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        switch status {
        case .notDetermined:
            print("NotDetermined")
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
        case .authorizedAlways:
            print("AuthorizedAlways")
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
            locationManager!.startUpdatingLocation()
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.first!
        self.mapView.centerCoordinate = location.coordinate
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager?.stopUpdatingLocation()
        locationManager = nil
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to initialize GPS: ", error.localizedDescription)
    }

    
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    
 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.inCreationEvent?.address = address
        self.inCreationEvent?.lati = lati
        self.inCreationEvent?.longi = longi
        let secondVC: timeSelector = segue.destination as! timeSelector
        secondVC.inCreationEvent = self.inCreationEvent
    }
    
    func draggablePanGestureAction(_ gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        view.frame.origin = CGPoint(x: 0, y: max(translation.y, 0) )
        if(translation.y > UIScreen.main.bounds.height * constants.gestureConstants.getureRemoveThreshold){
            view.removeGestureRecognizer(self.panGestureRecognizer)
            backBtnPressed(self)
        } else {
            let velocity = gesture.velocity(in: view)
            if gesture.state == .ended{
                if velocity.y >= constants.gestureConstants.gestureRemoveViewSpeed {
                    view.removeGestureRecognizer(self.panGestureRecognizer)
                    backBtnPressed(self)
                }
                else{
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.frame.origin = CGPoint(x: 0, y: 0)
                    })
                }
            }
        }
    }


}
