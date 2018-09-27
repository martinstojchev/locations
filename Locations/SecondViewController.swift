//
//  SecondViewController.swift
//  Locations
//
//  Created by Martin on 9/26/18.
//  Copyright © 2018 Martin. All rights reserved.
//

import UIKit
import MapKit

class SecondViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var requestedRoutePoints: [CLLocationCoordinate2D] = []
    
    let startPointCoordinates = CLLocationCoordinate2D(latitude: 42.00330699475713, longitude: 21.405449509620667)
    let endPointCoordinates   = CLLocationCoordinate2D(latitude: 41.99952385292592, longitude: 21.42538905143738)
    var routeSteps: [MKRoute.Step] = []
    var pinPointsCoordinate: [CLLocationCoordinate2D] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startPointCoordinates, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endPointCoordinates, addressDictionary:nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                self.routeSteps = route.steps
                self.printRouteSteps(steps: self.routeSteps)
                self.addPinPointsToMap(pinPointsCoordinate: self.pinPointsCoordinate, rootSteps: self.routeSteps)
            }
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
            
            mapView.addAnnotation(pinAnnotation)
            
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.green
        
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
        
        //print("pinPointsCoordinate count: \(pinPointsCoordinate.count)")
        print("Finished iterating the points.....")
        
        //pin the ending point
        mapView.addAnnotation(endingLocationPin)
        
        
        
        
        
        print("requestedRoutePoints array number of elements \(requestedRoutePoints.count)")
        
        return renderer
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
