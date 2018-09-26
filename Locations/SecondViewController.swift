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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.001783, longitude: 21.405396), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.0044269, longitude: 21.3894716), addressDictionary:nil))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.green
        
        let polyline = overlay as! MKPolyline
        var polyLinePoints = polyline.points()

        
        
        var i = 0
        while i < polyline.pointCount {
        
            requestedRoutePoints.append(polyLinePoints.pointee.coordinate)
            print("polyline pointee coordinate: \(polyLinePoints.pointee.coordinate)")
            
            let pinPoint = MyAnnotations(title: "pin",
                                  locationName: ".",
                                  discipline: ".",
                                  coordinate:polyLinePoints.pointee.coordinate )
            mapView.addAnnotation(pinPoint)

         polyLinePoints = polyLinePoints.successor()
            i = i + 1
        }
        
        print("Finished iterating the points.....")
        
        
        
        
        
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
