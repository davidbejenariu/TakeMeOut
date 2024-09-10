//
//  MainViewController.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 06.05.2023.
//

import UIKit
import MapKit
import FloatingPanel
import CoreLocation
import FirebaseAuth
import UserNotifications
import AVFoundation
import ARKit
import RealityKit

class MainViewController: UIViewController, ARSCNViewDelegate {
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    var panel = FloatingPanelController()
    var searchVC = SearchViewController()
    var detailsVC = DetailsViewController()
    var profileVC = ProfileViewController()
    
    let center = UNUserNotificationCenter.current()
    var canSendNotifications: Bool = false
    var applicationStarted: Bool = false
    var notificationSent: [String: Bool] = [:]
    
    var areDirectionsEnabled: Bool = false
    var steps: [MKRoute.Step] = []
    var stepId: Int = 1
    var turnId: Int = 1
    
    var selectedPolyline: MKPolyline?
    var routeDistance: CLLocationDistance?
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var arView = ARView()
    var startCoordinate: CLLocationCoordinate2D?
    var deviceHeading: CLLocationDirection?
    
    let locationBar: UIStackView = {
        let bar = UIStackView()
        
        bar.backgroundColor = .tertiarySystemBackground.withAlphaComponent(0.9)
        bar.layer.cornerRadius = 10
        bar.layer.shadowColor = UIColor.black.cgColor
        bar.layer.shadowOpacity = 0.3
        bar.layer.shadowRadius = 20
        bar.layer.shadowOffset = CGSize(width: 0, height: 15)
        bar.axis = .vertical
        bar.alignment = .center
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.layer.zPosition = 1
        
        return bar
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        
        label.text = "TakeMeOut"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let arrowDown: UIImageView = {
        let image = UIImageView()
        
        let arrowDownImage = UIImage(systemName: "arrow.down")
        let config = UIImage.SymbolConfiguration(paletteColors: [.label])
        config.applying(UIImage.SymbolConfiguration(weight: .bold))
        config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))
        
        image.preferredSymbolConfiguration = config
        image.image = arrowDownImage
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    let profileImage: UIImageView = {
        let image = UIImageView()

        let userImage = UIImage(systemName: "person.circle.fill")
        let config = UIImage.SymbolConfiguration(paletteColors: [.label])
        config.applying(UIImage.SymbolConfiguration(weight: .bold))
        
        image.preferredSymbolConfiguration = config
        image.image = userImage
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    let directionsBar: UIStackView = {
        let bar = UIStackView()
        
        bar.backgroundColor = .tertiarySystemBackground
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.layer.shadowColor = UIColor.black.cgColor
        bar.layer.shadowOpacity = 0.3
        bar.layer.shadowRadius = 20
        bar.layer.shadowOffset = CGSize(width: 0, height: 2)

        return bar
    }()
    
    let directionsView: UIStackView = {
        let view = UIStackView()
        
        view.backgroundColor = .tertiarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let directionsLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
//        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let directionsIcon: UIImageView = {
        let image = UIImageView()
        
        let config = UIImage.SymbolConfiguration(paletteColors: [.label])
        config.applying(UIImage.SymbolConfiguration(weight: .bold))
        config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))
        
        image.preferredSymbolConfiguration = config
        image.image = UIImage(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill")
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    var locationBarConstraints: [NSLayoutConstraint]?
    var directionsBarContraints: [NSLayoutConstraint]?
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            let loginViewController = LoginViewController()
            navigationController?.pushViewController(loginViewController, animated: false)
        }
        
        for value in categoryOf.values {
            categoryOf[value] = value
        }
        
        getCurrentLocation()
        searchVC.favouritesVC.loadFavourites()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        if Auth.auth().currentUser != nil {
            let currentUser = DataManager.shared.getUser(email: (Auth.auth().currentUser?.email)!)
            
            if currentUser != nil {
                if currentUser?.profileImage != nil {
                    profileImage.image = UIImage(data: (currentUser?.profileImage)!)
                }
            }
        }
        
        mapView.showsCompass = false
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.alpha = 1
        view.addSubview(mapView)
        
        arView.session.delegate = self
        arView.alpha = 0
        view.addSubview(arView)
        
        setLocationBar()
        setDirectionsBar()
        setSearchPanel()
        getCurrentLocation()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [self] (granted, error) in
            if granted {
                canSendNotifications = true
            } else {
                canSendNotifications = false
            }
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        nc.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapView.frame = view.bounds
        arView.frame = view.bounds
        
        profileImage.layer.cornerRadius = 15
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        panel.surfaceView.backgroundColor = .tertiarySystemBackground
        panel.move(to: .half, animated: true)
        applicationStarted = true
        
        locationManager.startUpdatingHeading()
    }
    
    func setSearchPanel() {
        searchVC.delegate = self
        searchVC.owner = self
        
        panel = FloatingPanelController()
        
        panel.set(contentViewController: searchVC)
        panel.delegate = self
        panel.addPanel(toParent: self)
        
        let appearance = SurfaceAppearance()
        
        if #available(iOS 13.0, *) {
            appearance.cornerCurve = .continuous
        }
        
        appearance.cornerRadius = 10
        panel.surfaceView.appearance = appearance
        panel.surfaceView.backgroundColor = .tertiarySystemBackground
        panel.view.layer.zPosition = 99
    }
    
    func setLocationBar() {
        view.addSubview(locationBar)
        locationBar.addSubview(locationLabel)
        locationBar.addSubview(arrowDown)
        locationBar.addSubview(profileImage)
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(updateLocation)
        )
        arrowDown.isUserInteractionEnabled = true
        arrowDown.addGestureRecognizer(tapGesture)
        
        let profileTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(goToProfile)
        )
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(profileTapGesture)
        
        locationBarConstraints = [
            locationBar.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -20),
            locationBar.heightAnchor.constraint(equalToConstant: 50),
            locationBar.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            locationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            locationLabel.centerXAnchor.constraint(equalTo: locationBar.centerXAnchor),
            locationLabel.centerYAnchor.constraint(equalTo: locationBar.centerYAnchor),
            locationLabel.topAnchor.constraint(equalTo: locationBar.topAnchor),
            arrowDown.topAnchor.constraint(equalTo: locationLabel.topAnchor, constant: 15),
            arrowDown.leadingAnchor.constraint(equalTo: locationBar.leadingAnchor, constant: 15),
            profileImage.topAnchor.constraint(equalTo: locationBar.topAnchor, constant: 10),
            profileImage.heightAnchor.constraint(equalTo: locationBar.heightAnchor, multiplier: 0.6),
            profileImage.widthAnchor.constraint(equalTo: profileImage.heightAnchor, multiplier: 1),
            profileImage.trailingAnchor.constraint(equalTo: locationBar.trailingAnchor, constant: -15)
        ]
        
        NSLayoutConstraint.activate(locationBarConstraints!)
    }
    
    func setDirectionsBar() {
        directionsView.addSubview(directionsLabel)
        directionsView.addSubview(directionsIcon)
        directionsBar.addSubview(directionsView)
        
        directionsLabel.numberOfLines = 0
        directionsLabel.lineBreakMode = .byWordWrapping
        
        directionsBarContraints = [
            directionsBar.topAnchor.constraint(equalTo: view.topAnchor),
            directionsBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            directionsBar.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            directionsBar.heightAnchor.constraint(equalToConstant: 130),
            directionsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            directionsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            directionsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            directionsView.bottomAnchor.constraint(equalTo: directionsBar.bottomAnchor),
            directionsIcon.leadingAnchor.constraint(equalTo: directionsView.leadingAnchor, constant: 20),
            directionsIcon.centerYAnchor.constraint(equalTo: directionsView.centerYAnchor),
            directionsIcon.heightAnchor.constraint(equalToConstant: 40),
            directionsIcon.widthAnchor.constraint(equalToConstant: 35),
            directionsLabel.leadingAnchor.constraint(equalTo: directionsIcon.trailingAnchor, constant: 20),
            directionsLabel.trailingAnchor.constraint(equalTo: directionsView.trailingAnchor, constant: -20),
            directionsLabel.centerYAnchor.constraint(equalTo: directionsIcon.centerYAnchor)
        ]
    }
    
    func getCurrentLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async { [self] in
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.allowsBackgroundLocationUpdates = true
                self.locationManager.pausesLocationUpdatesAutomatically = false
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    @objc func goToProfile() {
        profileVC = ProfileViewController()
        profileVC.owner = searchVC
        
        getCurrentLocation()
        
        if !mapView.overlays.isEmpty {
            mapView.removeOverlays(mapView.overlays)
        }
        
        panel.layout = PanelToTipLayout()
        panel.move(to: .tip, animated: true)
        panel.set(contentViewController: profileVC)
    }
    
    @objc func updateLocation() {
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else {
            return
        }

        mapView.setRegion(
            MKCoordinateRegion(
                center: locValue,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            animated: true
        )
    }
    
    @objc func appMovedToBackground() {
        locationManager.startUpdatingLocation()
    }
    
    @objc func appMovedToForeground() {
        locationManager.stopUpdatingLocation()
    }
    
    func alertForUpdatingLocation(_ locationData: CLLocation) {
        if Auth.auth().currentUser != nil {
            let currentUser = DataManager.shared.getUser(email: (Auth.auth().currentUser?.email)!)
            let favourites = DataManager.shared.getLocations(user: currentUser!)
            var closeTo: [Location] = []
            
            print(notificationSent)
            
            for favourite in favourites {
                if locationData.distance(from: CLLocation(latitude: favourite.latitude, longitude: favourite.longitude)) < 1000 && !notificationSent.keys.contains("\(favourite.latitude), \(favourite.longitude)") {
                    closeTo.append(favourite)
                }
            }
            
            print(closeTo.count)
            
            if !closeTo.isEmpty {
                for location in closeTo {
                    let content = UNMutableNotificationContent()
                    content.title = "Favourite location nearby!"
                    content.body = "You are close to \(location.name!)"
                    
                    notificationSent["\(location.latitude), \(location.longitude)"] = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [self] in
                        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                        
                        center.add(req) { err in
                            if err != nil {
                                print(err!.localizedDescription)
                            } else {
                                print("notification fired")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func addAnchors(forStep stepIndex: Int) {
//        print(stepIndex)
        let routeCoordinates = steps[stepIndex].polyline.coordinates
        var lineCoordinates: [CLLocationCoordinate2D] = []
        
        for i in 0 ..< routeCoordinates.count {
            lineCoordinates.append(routeCoordinates[i])
            
            if i < routeCoordinates.count - 1 {
                lineCoordinates.append(contentsOf: interpolatePoints(start: routeCoordinates[i], end: routeCoordinates[i + 1]))
            }
        }
        
        for coordinate in lineCoordinates {
            let position = getRelativePosition(from: startCoordinate!, to: coordinate)
//            let correctedPosition = adjustPositionWithCorrectionAngle(position: position, correctionAngle: getCorrectionAngle())
            
//            mapView.addOverlay(MKCircle(center: coordinate, radius: 10))
            addAnchor(at: position)
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }

        mapView.setRegion(
            MKCoordinateRegion(
                center: locValue,
                span: MKCoordinateSpan(latitudeDelta: areDirectionsEnabled ? 0.003 : 0.01, longitudeDelta: areDirectionsEnabled ? 0.003 : 0.01)
            ),
            animated: true
        )
        
        if UIApplication.shared.applicationState == .active {
            mapView.setRegion(
                MKCoordinateRegion(
                    center: locValue,
                    span: MKCoordinateSpan(latitudeDelta: areDirectionsEnabled ? 0.003 : 0.01, longitudeDelta: areDirectionsEnabled ? 0.003 : 0.01)
                ),
                animated: true
            )
            
            if areDirectionsEnabled {
                let currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
                let changePoint = CLLocation(latitude: steps[stepId].polyline.coordinate.latitude, longitude: steps[stepId].polyline.coordinate.longitude)
                let turnPoint = CLLocation(latitude: (selectedPolyline?.coordinates[turnId].latitude)!, longitude: (selectedPolyline?.coordinates[turnId].longitude)!)
                
                // change camera heading
                mapView.setCamera(
                    MKMapCamera(lookingAtCenter: locValue, fromDistance: 750, pitch: 0, heading: radiansToDegrees(radians: calculateBearing(from: locValue, to: turnPoint.coordinate))),
                    animated: true
                )
                print(mapView.camera.heading)
                
                if currentLocation.distance(from: changePoint) <= 5.0 {
                    if ARWorldTrackingConfiguration.isSupported {
                        if stepId < steps.count - 1 {
                            addAnchors(forStep: stepId + 1)
                        } else if stepId == steps.count - 1 {
                            // MARK: destination node
//                            addAnchors(forStep: stepId + 1)
                        }
                    }
                    
                    directionsLabel.text = steps[stepId].instructions
                    speechSynthesizer.speak(AVSpeechUtterance(string: steps[stepId].instructions))
                    
                    if stepId < steps.count - 1 {
                        stepId += 1
                    }
                }
                
                if currentLocation.distance(from: turnPoint) <= 5.0 {
                    if turnId < (selectedPolyline?.coordinates.count)! - 1 {
                        turnId += 1
                    }
                }
                
                let renderer = mapView.renderer(for: selectedPolyline!) as? MKPolylineRenderer
                renderer?.strokeStart = calculateProgress(to: locValue)
            } else {
                manager.stopUpdatingLocation()
            }
        } else if Auth.auth().currentUser != nil {
            if canSendNotifications && applicationStarted {
                alertForUpdatingLocation(CLLocation(latitude: locValue.latitude, longitude: locValue.longitude))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy > 0 else { return }
        deviceHeading = newHeading.magneticHeading
    }
    
    func calculateProgress(to location: CLLocationCoordinate2D) -> CGFloat {
        return CGFloat(getTraveledDistance(to: location) / routeDistance!)
    }

    func getTraveledDistance(to location: CLLocationCoordinate2D) -> CLLocationDistance {
        var distance: CLLocationDistance = 0
        var lastCoordinate = selectedPolyline?.coordinates[0]
        var currentCoordinate: CLLocationCoordinate2D?
        
        for i in 1 ..< turnId {
            currentCoordinate = selectedPolyline?.coordinates[i]
            distance += CLLocation(latitude: lastCoordinate!.latitude, longitude: lastCoordinate!.longitude).distance(from: CLLocation(latitude: (currentCoordinate?.latitude)!, longitude: (currentCoordinate?.longitude)!))
            lastCoordinate = currentCoordinate
        }
        
        distance += CLLocation(latitude: lastCoordinate!.latitude, longitude: lastCoordinate!.longitude).distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        return distance
    }
}

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            
            renderer.lineWidth = 7
            renderer.lineJoin = .round
            renderer.lineCap = .round
            renderer.lineDashPhase = 2
//            renderer.lineDashPattern = [0, NSNumber(nonretainedObject: renderer.lineWidth * 2)]
            
            if polyline == selectedPolyline {
                renderer.strokeColor = .systemBlue
            } else {
//                renderer.fillColor = .systemYellow
                renderer.strokeColor = .systemMint
            }
            
            return renderer
        } else if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            
            renderer.strokeColor = .systemRed
            renderer.fillColor = .systemPink
            renderer.alpha = 0.5
            
            return renderer
        }
        
        return MKOverlayRenderer()
    }
}

extension MainViewController: ARSessionDelegate {
    
}

extension MainViewController: SearchViewControllerDelegate {
    func searchViewController(_ vc: SearchViewController, didSelectLocation location: FavouriteModel) {
        let coordinate = location.mapItem!.placemark.coordinate
        
        panel.move(to: .half, animated: true)
        mapView.removeAnnotations(mapView.annotations)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = location.mapItem!.name
        
        mapView.addAnnotation(pin)
        
        mapView.setRegion(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            animated: true
        )
        
        detailsVC = DetailsViewController()
        detailsVC.owner = searchVC
        detailsVC.currentLocation = location
        detailsVC.renderFavouriteButton()
        panel.set(contentViewController: detailsVC)
        
        locationManager.stopUpdatingLocation()
    }
}

extension MainViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if panel.state == .tip || panel.state == .half {
            searchVC.deactivate(searchBar: searchVC.searchBar)
            
            var bottomInset: CGFloat = 0
            if panel.state == .half {
                bottomInset = view.frame.size.height - 15 - 350
            }
            
            detailsVC.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        } else {
            detailsVC.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func floatingPanel(_ fpc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        switch newCollection.verticalSizeClass {
        case .compact:
            return PanelLandscapeLayout()
        default:
            return PanelPortraitLayout()
        }
    }
}

class PanelPortraitLayout: FloatingPanelLayout {
    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
        .full: FloatingPanelLayoutAnchor(absoluteInset: 15.0, edge: .top, referenceGuide: .safeArea),
        .half: FloatingPanelLayoutAnchor(absoluteInset: 300.0, edge: .bottom, referenceGuide: .safeArea),
        .tip: FloatingPanelLayoutAnchor(absoluteInset: 140.0, edge: .bottom, referenceGuide: .safeArea),
    ]
}

class PanelLandscapeLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition  = .bottom
    let initialState: FloatingPanelState = .tip
    let anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
        .full: FloatingPanelLayoutAnchor(absoluteInset: 15.0, edge: .top, referenceGuide: .safeArea),
        .half: FloatingPanelLayoutAnchor(absoluteInset: 300.0, edge: .bottom, referenceGuide: .safeArea),
        .tip: FloatingPanelLayoutAnchor(absoluteInset: 140.0, edge: .bottom, referenceGuide: .safeArea),
    ]
    
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10.0),
            surfaceView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return 0.0
    }
}

class PanelToHalfLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition  = .bottom
    let initialState: FloatingPanelState = .tip
    let anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
        .half: FloatingPanelLayoutAnchor(absoluteInset: 300.0, edge: .bottom, referenceGuide: .safeArea),
        .tip: FloatingPanelLayoutAnchor(absoluteInset: 140.0, edge: .bottom, referenceGuide: .safeArea),
    ]
}

class PanelToTipLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition  = .bottom
    let initialState: FloatingPanelState = .tip
    let anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
        .tip: FloatingPanelLayoutAnchor(absoluteInset: 140.0, edge: .bottom, referenceGuide: .safeArea),
    ]
}
