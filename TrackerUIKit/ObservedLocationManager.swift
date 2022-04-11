//
//  ObservedLocationManager.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 11.04.2022.
//

import Foundation
import RxSwift
import CoreLocation

class ObservedLocationManager: NSObject {
    private var locationManager: CLLocationManager
    var coordinate: PublishSubject<CLLocationCoordinate2D>
    
    override init() {
        locationManager = CLLocationManager()
        coordinate = PublishSubject<CLLocationCoordinate2D>()
        super.init()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
}

extension ObservedLocationManager: CLLocationManagerDelegate {
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else { return }
        coordinate.onNext(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        coordinate.onError(error)
        print(error.localizedDescription)
    }
}
