//
//  MapViewController.swift
//  Test
//
//  Created by Kelin Christi on 1/19/16.
//  Copyright © 2016 Kelz. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import CoreMotion
import Moltin

class MapViewController: UIViewController,  MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var shakeMapView: MKMapView!
    
    let manager = CMMotionManager()
    
    var annotations: [MKAnnotation]?
    
    
    override func viewDidLoad() {

//        if let annotates = annotations {
//            print("HELLOW)")
//            shakeMapView.addAnnotations(annotates)
//            
//        }
        
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMDeviceMotion?, error: NSError?) in
                
                if data!.userAcceleration.x < -2.5 || data!.userAcceleration.x > 2.5{
                    self!.mapRandomZoom()
                }
            }
        }
        
        shakeMapView.showsUserLocation = true
        shakeMapView.userTrackingMode = MKUserTrackingMode.Follow
    }
    
    func mapRandomZoom() {
        let locationIndex = Int(arc4random_uniform(UInt32(annotations!.count)))
        let location = annotations![locationIndex].coordinate
        let span = MKCoordinateSpanMake(0.002, 0.002)
        let region = MKCoordinateRegionMake(location , span)
        shakeMapView.setRegion(region, animated: true)
    }
    
}


