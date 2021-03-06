//
//  ViewController.swift
//  Locations
//
//  Created by Martin on 9/25/18.
//  Copyright © 2018 Martin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
    var previousLocations: [CLLocation] = []
    
    let cityMallCoordinates = CLLocationCoordinate2D(latitude: 42.0044232, longitude: 21.3829109)
    let skopjeZooCoordinates = CLLocationCoordinate2D(latitude: 42.0043068, longitude: 21.3969873)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            checkLocationServices()
        
        //createMapPoints()
        directions()
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) ->MKOverlayRenderer {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = UIColor.blue
            return renderer
        }

    }
    
    func createMapPoints(){
        
        let cityMallMapPoint = MKMapPoint(cityMallCoordinates)
        
        let skopjeZooMapPoint = MKMapPoint(skopjeZooCoordinates)
        
        let cityMallLocation = CLLocation(latitude: cityMallCoordinates.latitude, longitude: cityMallCoordinates.longitude)
        let skopjeZooLocation = CLLocation(latitude: skopjeZooCoordinates.latitude, longitude: skopjeZooCoordinates.longitude)
        //let usersLocationCoordinates = mapView.userLocation.coordinate
        //let usersLocationMapPoint = MKMapPoint(usersLocationCoordinates)
        
        let distance = cityMallLocation.distance(from: skopjeZooLocation)
        
        
        print("distance between two CLLocations: \(distance)")
        
        //let pointsPerMeterAtLatitude = MKMapPointsPerMeterAtLatitude(cityMallMapPoint.coordinate.latitude)
        
        //print("pointsPerMeterAtLatitude : \(pointsPerMeterAtLatitude)")
    }
    
    // request and response for MKDirections
    func directions(){
        
        let skopjeZooMapItem = MKMapItem(placemark: MKPlacemark(coordinate: skopjeZooCoordinates))
        let cityMallMapItem = MKMapItem(placemark: MKPlacemark(coordinate: cityMallCoordinates))
        
        let request = MKDirections.Request()
        request.source = skopjeZooMapItem
        request.destination = cityMallMapItem
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes{
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                print("overlay added")
            }
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    
    
    
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate {
             let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            
            
        }
        
        
        
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
    
    
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        
        if(mapView.userLocation.isUpdating){
        previousLocations.append(location)
        
        //print("User's updating location: \(location.coordinate.latitude),\(location.coordinate.longitude) ")
        
        //print("locations items #: \(previousLocations.count)")
        
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //we'll be back
        checkLocationAuthorization()
    }
    
}
