//
//  MasterViewController.swift
//  Test
//
//  Created by Kelin Christi on 1/18/16.
//  Copyright © 2016 Kelz. All rights reserved.
//

import UIKit
import MapKit
import Moltin

class MasterViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var annotationsForMapViewController = [MKAnnotation]()
    
    var detailViewController: DetailViewController? = nil
    
    //All the objects will be stored here and when cell asks for data, we will access this array also.
    var objects = [AnyObject]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //This is where we initialize the moltin SDK
        Moltin.sharedInstance().setPublicId("aqA2mV2YKWpmu4daVS7Fh2WbWLH0xe1f2i9hHrkR")
        
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        //We make a call to the Moltin API to retrieve store products
        
        Moltin.sharedInstance().product.listingWithParameters(nil, success:
            { (responseDictionary) -> Void in
                
                //assign products array to object array
                self.objects = responseDictionary["result"] as! [AnyObject]
                
                //Tells tableView to reload data
                self.tableView.reloadData()
            })
            { (responseDictionary, error) -> Void in
                print("RUH ROH")
            }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        //
        let object = objects[indexPath.row] as! NSDictionary
        cell.textLabel!.text = object["title"] as? String
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Segues
    
    //When a user taps a table view cell, this chunk of code gets fired.
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //It checks if the segue that is being triggered is the "showDetail" segue
        if segue.identifier == "showDetail" {
            
            //Here we check whether a user has selected a row in the table view
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                //now, based on the row the user selected, we go into the objects array and retrieve the object which is a dictionary
                let object = objects[indexPath.row] as! NSDictionary
                
                //Reference to the DetailViewController which is the destination viewcontroller we are going to
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                
                //we then access the detailItem in the DetailViewController and assign it our object(product)
                controller.detailItem = object
                
                //This just sets the back button
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "mapSegue" {
            let mapController = segue.destinationViewController as! MapViewController
            for object in objects {
//                print("THIS IS AN OBJECTS ******************** \(object)")\
                let address = object["address"] as! String
                let title = object["title"] as! String
                let price = object.valueForKeyPath("price.data.formatted.with_tax") as! String
                
                self.forwardGeocoding(address, title: title, price: price)
            
//                
//                print("Address: \(address)")
//                print("Title: \(title)")
//                print("Price: \(price)")
                
            }
            mapController.annotations = annotationsForMapViewController
        }
    }
    
    func forwardGeocoding(address: String, title: String, price: String) {
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
                
                // custom modification
                restaurantPin.title = title
                restaurantPin.subtitle = price
                self.annotationsForMapViewController.append(restaurantPin)

            }
        })
}
}

