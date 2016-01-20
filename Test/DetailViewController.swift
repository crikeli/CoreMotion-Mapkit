//
//  DetailViewController.swift
//  Test
//
//  Created by Kelin Christi on 1/18/16.
//  Copyright © 2016 Kelz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI
import Moltin

class DetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var detailTitleLabel: UILabel!

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    @IBOutlet weak var detailPriceLabel: UILabel!
    
    @IBOutlet weak var detailAddressLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
//    var restaurantPin: MKPointAnnotation?
    
    let locationManager = CLLocationManager()
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            
                //Set the product title
                let productTitle = detail["title"] as? String
            if let title = productTitle {
                self.detailTitleLabel?.text = title
            }
            
                //Set the description label
                let productDescription = detail["description"] as? String
            if let desc = productDescription {
                self.detailDescriptionLabel?.text = desc
            }
            
                //Set the price label
                let productPrice = detail.valueForKeyPath("price.data.formatted.with_tax") as? String
            if let price = productPrice {
                self.detailPriceLabel?.text = price
            }
            
                //Set the address label
                let productAddress = detail["address"] as? String
            if let addr = productAddress {
                self.detailAddressLabel?.text = addr
                
                
                //Geocoding function (forward)
                //completion handlers return an array of placemarkers
                func forwardGeocoding(address: String) {
                    CLGeocoder().geocodeAddressString(address , completionHandler: { (placemarks, error) in
                        if error != nil {
                            print(error)
                            return
                        }
                        //Here, we check how many placemarks are found pertaining to the input above.
                        //If there are placemarks, we get all the information about the first one.
                        //I then printed the lats and longs to see if I was getting right results.
                        if placemarks?.count > 0 {
                            let placemark = placemarks?[0]
                            let location = placemark?.location
                            let coordinate = location?.coordinate
                            print("lat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                            
                            //Declared a constant that is able to leverage the CLLocationCoordinate2D to get the latitude and longitude co-ordinates
                            //Declared another constant that instantiated the MKPointAnnotation that is responsible for the pin
                            let destination : CLLocationCoordinate2D = CLLocationCoordinate2DMake(coordinate!.latitude, coordinate!.longitude)
                            let restaurantPin = MKPointAnnotation()
                            restaurantPin.coordinate = destination
                            self.mapView.addAnnotation(restaurantPin)
                        }
                    })
                }
                
                //Address to co-ordinates
                forwardGeocoding(addr)
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //getting last location
        let location = locations.last
        
        //getting the center of the location
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        //zoom range
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15))
        
        //animation
        self.mapView.setRegion(region, animated: true)
        
        //since we have a zoomed view, we stop updating the location
        self.locationManager.stopUpdatingLocation()
        
    }
    
    
    // Here is the logic that is responsible for adding items to the cart to simulate ecommerce.
    @IBAction func addToCartTapped(sender: AnyObject) {
        //get the product id
        let productid = self.detailItem?["id"] as? String
        
        if let id = productid {
            
            //Add to cart
            Moltin.sharedInstance().cart.insertItemWithId(id, quantity: 1, andModifiersOrNil: nil, success: { (responseDictionary) -> Void in
                
                // Display a message to the user that the item has been added
                
                let alert = UIAlertController(title: "Added Item to Cart", message: "GRAZIE :)",  preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title:"Sounds Good!", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion:nil )
                }, failure: { (responseDictionary, error) -> Void in
                
                    //Could not load the product
                print("RUH ROH")
                    
            })
        }
    }
}

