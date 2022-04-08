//
//  ViewController.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 19.03.2022.
//

import UIKit
import GoogleMaps
import CoreLocation
import RealmSwift

class MapViewController: UIViewController, Storyboarded{

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var loadTrackButton: UIButton!
    @IBOutlet weak var setCurrentLocationButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    
    var locationManager: CLLocationManager?
    var polylines = [GMSPolyline]()
    var path: GMSMutablePath?
    var fullPath: GMSMutablePath?
    var isTracking = false
    var needToSetCurrentLocation = true
    let trackingZoom: Float = 15.0
    var zoom: Float = 15.0
    var realmTrack: Track?
    
    var realm: Realm?
    var tracks: Results<Track>?
    
    var coordinator: MapViewCoordinator?
    @UserDefault(key: "userId", defaultValue: nil) var userId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRealm()
        configureMap()
        configureButtons()
        configureLocationManager()
    }

    private func configureRealm() {
        if realm == nil {
            showAlert("Ошибка!", "Не могу соединиться с базой данных, сохранение треков недоступно", withCancelButton: false, nil)
        }
        tracks = realm?.objects(Track.self)
    }
    
    private func configureMap() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
        let camera = GMSCameraPosition(target: coordinate, zoom: zoom)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.tintColor = .blue
        mapView.delegate = self
    }
    
    private func configureButtons() {
        startPauseButton.setTitle("", for: .normal)
        stopButton.setTitle("", for: .normal)
        loadTrackButton.setTitle("", for: .normal)
        setCurrentLocationButton.setTitle("", for: .normal)
        zoomInButton.setTitle("", for: .normal)
        zoomOutButton.setTitle("", for: .normal)
        exitButton.setTitle("", for: .normal)
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
    }

    @IBAction func didTapSetCurrentLocationButton(_ sender: Any) {
        needToSetCurrentLocation = true
        zoom = trackingZoom
        locationManager?.requestLocation()
    }
    
    @IBAction func didTapStartPauseButon(_ sender: Any) {
        isTracking.toggle()
        let buttonImage = isTracking ? UIImage(systemName: "pause") : UIImage(systemName: "play")
        startPauseButton.setImage(buttonImage, for: .normal)
        
        if realmTrack == nil {
            realmTrack = Track()
            polylines.forEach { $0.map = nil }
            polylines = []
            fullPath = GMSMutablePath()
        } else {
            realmTrack?.encodedPaths.append(path?.encodedPath())
        }
        path = GMSMutablePath()
        polylines.append(GMSPolyline())
        
        polylines.last?.strokeWidth = 3
        polylines.last?.map = mapView
    }
    
    @IBAction func didTapStopButton(_ sender: Any) {
        saveTrack(completion: nil)
    }
    
    @IBAction func didTapExitButton(_ sender: Any) {
        let message = isTracking ? "Завершить текущий трек и выйти?" : "Выйти из акквунта?"
        showAlert("Внимание!", message) { [weak self] _ in
            guard let self = self else { return }
            if self.isTracking {
                self.saveTrack(completion: { self.coordinator?.didFinish() })
            } else {
                self.coordinator?.didFinish()
            }
        }
    }
    
    private func saveTrack(completion: (() -> Void)?) {
        isTracking = false
        startPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
        guard let path = path, let realmTrack = realmTrack, let fullPath = fullPath else { return }
        realmTrack.encodedPaths.append(path.encodedPath())
        realmTrack.fullPath = fullPath.encodedPath()
        realmTrack.endDate = Date()
        realmTrack.userId = userId ?? ""
        do {
            try realm?.write {
                realm?.add(realmTrack)
            }
        }
        catch {
            showAlert("Ошибка!", "Что-то пошло не так. Не могу сохранить трек", withCancelButton: false) { _ in
                self.realmTrack = nil
                self.path = nil
                self.fullPath = nil
                return
            }
        }
        self.realmTrack = nil
        self.path = nil
        self.fullPath = nil
        showAlert("Поздравляю!", "Трек успешно сохранен", withCancelButton: false) { _ in
            (completion ?? {})()
        }
    }
    
    @IBAction func didTapLoadTrackButton(_ sender: Any) {
        let completion = {[weak self] in
            guard let self = self else { return }
            let tracksViewController = TracksViewController()
            if let userId = self.userId {
                tracksViewController.tracks = self.tracks?.where { $0.userId == userId }
            }
            tracksViewController.completion = { encodedPaths, encodedFullPath in
                encodedPaths.forEach { encodedPath in
                    guard let encodedPath = encodedPath else { return }
                    let path = GMSPath(fromEncodedPath: encodedPath)
                    let polyline = GMSPolyline(path: path)
                    polyline.map = self.mapView
                    self.polylines.append(polyline)
                }
                if let encodedFullPath = encodedFullPath, let fullPath = GMSPath(fromEncodedPath: encodedFullPath) {
                    let bounds = GMSCoordinateBounds(path: fullPath)
                    self.mapView.animate(with: GMSCameraUpdate.fit(bounds))
                }
            }
            self.realmTrack = nil
            self.polylines.forEach { $0.map = nil }
            self.polylines = []
            self.present(tracksViewController, animated: true)
        }
        
        if realmTrack != nil {
            showAlert("Attention!", "Stop recording track and load the other one from database?") { _ in
                self.saveTrack(completion: completion)

            }
        } else {
            completion()
        }
    }
    
    @IBAction func didTapZoomInButton(_ sender: Any) {
        if zoom < 20 {
            zoom += 1
        }
        mapView.animate(toZoom: zoom)
    }
    
    @IBAction func didTapZoomOutButton(_ sender: Any) {
        if zoom > 1 {
            zoom -= 1
        }
        mapView.animate(toZoom: zoom)
    }
}

extension MapViewController: GMSMapViewDelegate {

}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.first?.coordinate, isTracking || needToSetCurrentLocation else { return }
        
        let position = GMSCameraPosition(target: coordinate, zoom: zoom)
        path?.add(coordinate)
        fullPath?.add(coordinate)
        polylines.last?.path = path
        mapView.animate(to: position)
        needToSetCurrentLocation = false   
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

