//
//  ViewController.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 19.03.2022.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager: CLLocationManager?
    var track: GMSPolyline?
    var path: GMSMutablePath?
    //var camera: GMSCameraPosition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
        configureLocationManager()
    }

    private func configureMap() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
        let camera = GMSCameraPosition(target: coordinate, zoom: 15)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        path = GMSMutablePath()
        track = GMSPolyline()
        track?.strokeWidth = 3
        track?.map = mapView
        mapView.delegate = self
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
    }

}

extension MapViewController: GMSMapViewDelegate {
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate else { return }
        
        let position = GMSCameraPosition(target: coordinate, zoom: 15)
        path?.add(coordinate)
        track?.path = path
        mapView.animate(to: position)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
