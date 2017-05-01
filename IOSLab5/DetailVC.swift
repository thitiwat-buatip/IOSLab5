//
//  DetailVC.swift
//  IOSLab5
//
//  Created by Thitiwat on 4/25/2560 BE.
//  Copyright © 2560 Thitiwat. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
import Firebase
import FirebaseDatabase

class DetailVC: UIViewController {
    @IBOutlet weak var ipFlied: UITextField!
    var continent : String?
    var state = String()
    var longitude = Double()
    var latitude = Double()
    var country : String?
    let regionRadius: CLLocationDistance = 1000
    var initialLocation = CLLocation()
    var ref: FIRDatabaseReference!
    let userID = UserDefaults.standard.object(forKey: "userid") as! String
    

    @IBOutlet weak var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadData(ip: "202.28.250.85")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func addAnnotations(coords: CLLocation){
        let yourAnnotationAtIndex = 0
        let CLLCoordType = CLLocationCoordinate2D(latitude: coords.coordinate.latitude, longitude: coords.coordinate.longitude)
        let anno = MKPointAnnotation()
        anno.coordinate = CLLCoordType
        anno.title = "Here That IP"
        anno.subtitle = "lat : \(latitude) long : \(longitude)"
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(mapView.annotations[yourAnnotationAtIndex], animated: true)
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil;
        }else{
            let pinIdent = "Pin"
            var pinView: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdent) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
            }else{
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdent)
                
            }
            return pinView;
        }
    }
    @IBAction func search(_ sender: Any) {
        ref = FIRDatabase.database().reference().child("History").child(userID).childByAutoId()
        if let ip = ipFlied.text {
            loadData(ip: ip)
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'|'HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: -7)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            let posted = ["Time": formatter.string(from: date),
                          "IP": ip]
            ref.updateChildValues(posted)

        }
    }
    @IBAction func hisTapped(_ sender: Any) {
        performSegue(withIdentifier: "history", sender: nil)
    }
 
    func loadData(ip : String) {
        Alamofire.request("http://geo.groupkt.com/ip/\(ip)/json").responseJSON { response in
            print(response.request!)  // original URL request
            print(response.response!) // HTTP URL response
            print(response.data!)     // server data
            print(response.result)   // result of response serialization
            
            if let JSON = response.value as? [String : Any]{
                if let result = JSON["RestResponse"] as? [String : Any]{
                    if let value =  result["result"] as? [String : Any] {
                        self.continent = value["continent"] as? String
                        self.state = (value["state"] as? String)!
                        self.longitude = (value["longitude"] as? Double)!
                        self.latitude = (value["latitude"] as? Double)!
                        self.country = value["country"] as? String
                        print(self.longitude)
                        print(self.latitude)
                        self.initialLocation = CLLocation(latitude: self.latitude , longitude: self.longitude)
                        self.centerMapOnLocation(location: self.initialLocation)
                        self.addAnnotations(coords: self.initialLocation)
                    }
                }
            }
        }
    }

    @IBAction func logout(_ sender: Any) {
        let mainStory: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        
        let desController = mainStory.instantiateViewController(withIdentifier:"ViewController") as! ViewController
        
        self.present(desController, animated: true, completion: nil)
    }
    
}
