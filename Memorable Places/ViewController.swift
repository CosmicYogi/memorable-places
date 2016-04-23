//
//  ViewController.swift
//  Memorable Places
//
//  Created by mitesh soni on 23/04/16.
//  Copyright © 2016 Mitesh Soni. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate , CLLocationManagerDelegate{
    @IBOutlet var map: MKMapView!

    var manager : CLLocationManager!
    var user_latitude : CLLocationDegrees!
    var user_longitude : CLLocationDegrees!
    var titleAnnotation : String = " ";
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = CLLocationManager();
        manager.delegate = self;
        manager.desiredAccuracy = kCLLocationAccuracyBest;

        if (activePlace == -1){
            manager.requestWhenInUseAuthorization();
            manager.startUpdatingLocation();
        }
        else{
            let latitude = Double(places[activePlace]["lat"]!);
            let longitude = Double (places[activePlace]["lon"]!);
            
            let delx = 0.01;
            let dely = 0.01;
            
            let span : MKCoordinateSpan = MKCoordinateSpanMake(delx, dely);
            let coordinates : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!);
            let region : MKCoordinateRegion = MKCoordinateRegionMake(coordinates, span)
            self.map.setRegion(region, animated: true);
            
            var annotation = MKPointAnnotation ();
            annotation.coordinate = coordinates;
            annotation.title = places[activePlace]["name"];
            self.map.addAnnotation(annotation);
            
            
        }
        let longPress = UILongPressGestureRecognizer(target: self, action: "addAnnotations:");
        longPress.minimumPressDuration = 2;
        map.addGestureRecognizer(longPress);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        user_latitude  = locations[0].coordinate.latitude;
        user_longitude = locations[0].coordinate.longitude;
        let deltaX : CLLocationDegrees = CLLocationDegrees(0.01);
        let deltaY : CLLocationDegrees = CLLocationDegrees(0.01);
        
        let span : MKCoordinateSpan = MKCoordinateSpanMake(deltaX, deltaY);
        let coordinates : CLLocationCoordinate2D = CLLocationCoordinate2DMake(user_latitude , user_longitude);
        let region : MKCoordinateRegion = MKCoordinateRegionMake(coordinates, span);
        
        map.setRegion(region, animated: true);

    }
    
    func addAnnotations(gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state == UIGestureRecognizerState.Began){
            let point = gestureRecognizer.locationInView(self.map);
            let coordinates = self.map.convertPoint(point, toCoordinateFromView: self.map);
            
            //print(coordinates.latitude)
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude);
            CLGeocoder().reverseGeocodeLocation(location) { (placeMarks, errors) -> Void in
                if (errors == nil) {
                    if let p = placeMarks?[0]{
                        var subThroughFare : String = "";
                        var throughFare : String = "";
                        if (p.subThoroughfare != nil){
                            subThroughFare = p.subThoroughfare!;
                        }
                        else{
                            print("subThrough fare is nil");
                        }
                        if (p.thoroughfare != nil){
                            throughFare = p.thoroughfare!;
                        }
                        else{
                            print("throughFare is nil");
                        }
                        self.titleAnnotation = "\(subThroughFare) \(throughFare)";
                        print("title is \(self.titleAnnotation)");
                    }
                    else{
                        print("aapke saath to lol ho gaya");
                    }
                }
                else{
                    print(errors);
                }
            }
            
            places.append(["name":titleAnnotation,"lat":"\(coordinates.latitude)","lon":"\(coordinates.longitude)"]);
            var annotation = MKPointAnnotation();
            annotation.title = "Added \(titleAnnotation)";
            annotation.coordinate = coordinates;
            annotation.subtitle = "This place is added to memorable places"
            map.addAnnotation(annotation)
            
            NSUserDefaults.standardUserDefaults().setObject(places, forKey: "placesList");
        }
    }
}

