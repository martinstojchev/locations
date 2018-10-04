//
//  SecondViewController.swift
//  Locations
//
//  Created by Martin on 9/26/18.
//  Copyright © 2018 Martin. All rights reserved.
//

import UIKit
import MapKit

class SecondViewController: UIViewController, MKMapViewDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var requestedRoutePoints: [CLLocationCoordinate2D] = []
    var startPointCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var endPointCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var routeSteps: [MKRoute.Step] = []
    var pinPointsCoordinate: [CLLocationCoordinate2D] = []
    var usersCurrenLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var requestedRouteForTap: Bool = false
    var directionsForRoute:[MKDirections] = []
    var annotationsOnMap: [MyAnnotations] = []
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkLocationServices()
        
        self.mapView.delegate = self
        self.setupGesture()
        
        
        
       
    }
    
    func setupGesture() {
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(SecondViewController.handleLongPress(gestureRecognizer:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.delegate = self
        self.mapView.addGestureRecognizer(longPressGesture)
        
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        
        if gestureRecognizer.state != UIGestureRecognizer.State.ended {
            
            if requestedRouteForTap == false {
            requestedRouteForTap = true
                
            let touchLocation = gestureRecognizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            print("Tapped location: \(locationCoordinate.latitude),\(locationCoordinate.longitude)")
            requestRoute(endLocation: locationCoordinate)
            cancelButton.isHidden = false
            return
            
            }
        }
        
        if gestureRecognizer.state != UIGestureRecognizer.State.began {
            return
        }
        
    }
    
    func requestRoute(endLocation: CLLocationCoordinate2D){
        
         startPointCoordinates = usersCurrenLocation
         endPointCoordinates   = endLocation
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: usersCurrenLocation, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endLocation, addressDictionary:nil))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directionsForRoute.append(directions)
        
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            var allRoutes = unwrappedResponse.routes
            let bestRoute = allRoutes.sorted(by: {$0.expectedTravelTime <
                $1.expectedTravelTime})[0]
            
      
            //for route in unwrappedResponse.routes {
                
                self.mapView.addOverlay(bestRoute.polyline)
                self.mapView.setVisibleMapRect(bestRoute.polyline.boundingMapRect, animated: true)
                self.routeSteps = bestRoute.steps
                self.printRouteSteps(steps: self.routeSteps)
                self.addPinPointsToMap(pinPointsCoordinate: self.pinPointsCoordinate, rootSteps: self.routeSteps)
                
                print("best route showed")
            //}
        }
        
      
    }
    
    func printRouteSteps(steps: [MKRoute.Step]) {
        
        for routeStep in steps {
            print("routeStep: \(routeStep.instructions, routeStep.polyline.coordinate)")
        }
    }
    
    func addPinPointsToMap(pinPointsCoordinate: [CLLocationCoordinate2D], rootSteps: [MKRoute.Step]) {
        
        for pinPoint in pinPointsCoordinate {
            
            let pinLatitude  = pinPoint.latitude
            let pinLongitude = pinPoint.longitude
            var stepDirection = ""
            
            for step in rootSteps {
                
                let stepLatitude  = step.polyline.coordinate.latitude
                let stepLongitude = step.polyline.coordinate.longitude
                
                if (stepLatitude == pinLatitude && stepLongitude == pinLongitude){
                    
                    
                    stepDirection = step.instructions
                }
                
            }
            
            let pinAnnotation = MyAnnotations(title: "",
                                              locationName: stepDirection,
                                              discipline: "",
                                              coordinate: pinPoint)
            
            annotationsOnMap.append(pinAnnotation)
            
            mapView.addAnnotation(pinAnnotation)
            
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        
        //renderer.alpha = 0.1
        
        print("overlays count: \(mapView.overlays.count)")
        //coloring the routes
        if(overlay is MKPolyline){

            print("overlay is MKPolyline")
            if mapView.overlays.count == 1 {
                 renderer.strokeColor = UIColor.blue.withAlphaComponent(0.5)
            }
            else if (mapView.overlays.count == 2) {
              renderer.strokeColor = UIColor.green.withAlphaComponent(0.5)
            }
            else if (mapView.overlays.count == 3) {
                renderer.strokeColor = UIColor.red.withAlphaComponent(0.5)
            }
        }
        
        
        
        let polyline = overlay as! MKPolyline
        var polyLinePoints = polyline.points()

        
        
        
        
        
         let startingLocationPin = MyAnnotations(title: "Start",
                                                 locationName: "Start point",
                                                 discipline: "",
                                                 coordinate: startPointCoordinates
                                                )
        
        let endingLocationPin    = MyAnnotations(title: "End",
                                                 locationName: "End point",
                                                 discipline: "",
                                                 coordinate: endPointCoordinates
                                                )
        
        //pin the starting point
        annotationsOnMap.append(startingLocationPin)
        mapView.addAnnotation(startingLocationPin)
        
        var i = 0
        while i < polyline.pointCount {
        
            requestedRoutePoints.append(polyLinePoints.pointee.coordinate)
            print("polyline pointee coordinate: \(polyLinePoints.pointee.coordinate)")
            print("polyline pointee coordinate: \(polyLinePoints.pointee.coordinate)")
            
            
//            let pinPoint = MyAnnotations(title: "pin",
//                                  locationName: "\(polyLinePoints.pointee.coordinate.latitude), \(polyLinePoints.pointee.coordinate.longitude)",
//                                  discipline: ".",
//                                  coordinate:polyLinePoints.pointee.coordinate )
//            mapView.addAnnotation(pinPoint)
            pinPointsCoordinate.append(polyLinePoints.pointee.coordinate)
            

         polyLinePoints = polyLinePoints.successor()
            i = i + 1
        }
        
        for ppCoordinate in pinPointsCoordinate {
        
            
            print("pinPointsCoordinate: lat:\(ppCoordinate.latitude), lon:\(ppCoordinate.longitude)")
        
        }
        
        print("pinPointsCoordinate count: \(pinPointsCoordinate.count)")
        print("Finished iterating the points.....")
        
        //pin the ending point
        annotationsOnMap.append(endingLocationPin)
        print("endPointCoordinate: lat: \(endingLocationPin.coordinate.latitude), lon: \(endingLocationPin.coordinate.longitude)")
        mapView.addAnnotation(endingLocationPin)
        
        
        
        
        
        print("requestedRoutePoints array number of elements \(requestedRoutePoints.count)")
        
        return renderer
    }
    
    func setupLocationManager() {
        
       // locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    
    func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            //setup our location manager
            setupLocationManager()
            checkLocationAuthorization()
            
            
            
        }
        else {
            // Show alert letting the user know they have to turn this on.
        }
        
        
    }
    
    func checkLocationAuthorization(){
        
        switch CLLocationManager.authorizationStatus(){
            
        case .authorizedWhenInUse:
            
            mapView.showsUserLocation = true
            //centerViewOnUserLocation()
            print("authorization when in use")
            locationManager.startUpdatingLocation()
            
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
            
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //print("Updating user's location: \(userLocation.coordinate)")
        
        
        if (usersCurrenLocation.latitude == 0 && usersCurrenLocation.longitude == 0) {
            usersCurrenLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            print("User's current location: \(usersCurrenLocation)")
            
        }
    }
    
  
    @IBAction func cancelRoute(_ sender: Any) {
    
        //print("directionsForRoute count: \(directionsForRoute.count)")
        
        mapView.removeAnnotations(annotationsOnMap)
        pinPointsCoordinate = []
    
        //print("Annotations removed from map")
        
        if mapView.overlays.count > 0 {
        
            mapView.removeOverlays(mapView.overlays)
            
    
        }
        requestedRouteForTap = false
        cancelButton.isHidden = true
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension ViewController: CLLocationManagerDelegate {
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        guard let location = locations.last else {return}
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
//
//        if(mapView.userLocation.isUpdating){
//            previousLocations.append(location)
//
//            //print("User's updating location: \(location.coordinate.latitude),\(location.coordinate.longitude) ")
//
//            //print("locations items #: \(previousLocations.count)")
//
//        }
//
//
//    }
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        //we'll be back
//        checkLocationAuthorization()
//    }
//
//}
