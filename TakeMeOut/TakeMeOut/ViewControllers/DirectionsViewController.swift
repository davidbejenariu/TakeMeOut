//
//  DirectionsViewController.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 24.05.2023.
//

import UIKit
import MapKit
import AVFoundation
import ARKit

class DirectionsViewController: UIViewController {
    var owner: RoutesViewController?
    var mainVC: MainViewController?
    
    var route: MKRoute?
    var routeOverlays: [MKOverlay]?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Walking to"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let endButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("End Route", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let viewInARButton = CustomButton(labelText: "View in AR", systemImageName: "arkit", buttonColor: .systemBlue)
    var viewInARButtonContraints: [NSLayoutConstraint]?
    
    let mapViewButton = CustomButton(labelText: "Map View", systemImageName: "map", buttonColor: .systemMint)
    var mapViewButtonConstraints: [NSLayoutConstraint]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .tertiarySystemBackground
        
        mainVC?.steps = route!.steps
        mainVC?.stepId = 1
        mainVC?.turnId = 1
        
        mainVC?.locationManager.startUpdatingLocation()
        mainVC?.areDirectionsEnabled = true
        
        mainVC?.locationBar.removeFromSuperview()
        mainVC?.view.removeConstraints((mainVC?.locationBarConstraints)!)
        
        mainVC?.view.addSubview(mainVC!.directionsBar)
        NSLayoutConstraint.activate(mainVC!.directionsBarContraints!)
        
//        mainVC?.mapView.overrideUserInterfaceStyle = .dark
        routeOverlays = mainVC?.mapView.overlays
        mainVC?.mapView.removeOverlays(routeOverlays!)
        mainVC?.mapView.addOverlay(route!.polyline)
        
        setUpARSession()
        
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        view.addSubview(titleLabel)
        
        endButton.addTarget(self, action: #selector(goToDetailsView), for: .touchUpInside)
        view.addSubview(endButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            endButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            endButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            endButton.heightAnchor.constraint(equalToConstant: 45),
        ])
        
        if ARWorldTrackingConfiguration.isSupported {
            viewInARButton.addTarget(self, action: #selector(viewInAR), for: .touchUpInside)
            viewInARButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(viewInARButton)
            
            viewInARButtonContraints = [
                viewInARButton.topAnchor.constraint(equalTo: endButton.topAnchor),
                viewInARButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
                viewInARButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -10),
                viewInARButton.heightAnchor.constraint(equalToConstant: 45),
            ]
            
            mapViewButtonConstraints = [
                mapViewButton.topAnchor.constraint(equalTo: endButton.topAnchor),
                mapViewButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
                mapViewButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -10),
                mapViewButton.heightAnchor.constraint(equalToConstant: 45),
            ]
            
            endButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 10).isActive = true
            NSLayoutConstraint.activate(viewInARButtonContraints!)
            
            guard let locValue: CLLocationCoordinate2D = mainVC!.locationManager.location?.coordinate else {
                return
            }
            mainVC!.startCoordinate = locValue
            
            mainVC?.addAnchors(forStep: 0)
            mainVC?.addAnchors(forStep: 1)
        } else {
            endButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30).isActive = true
        }
        
        let steps = route?.steps
        
//        for i in 0 ..< steps!.count {
//            let step = steps![i]
//            print(step.instructions)
//
//            let region = CLCircularRegion(center: step.polyline.coordinate, radius: 10, identifier: "\(i)")
//            mainVC?.mapView.addOverlay(MKCircle(center: region.center, radius: region.radius))
//            mainVC!.locationManager.stopUpdatingLocation()
//        }
        
        mainVC?.directionsLabel.text = steps![0].instructions
        mainVC?.speechSynthesizer.speak(AVSpeechUtterance(string: steps![0].instructions))
    }
    
    func setUpARSession() {
        let configuration = ARWorldTrackingConfiguration()
//        configuration.worldAlignment = .gravityAndHeading
        mainVC!.arView.session.run(configuration)
        
        guard let locValue: CLLocationCoordinate2D = mainVC!.locationManager.location?.coordinate else {
            return
        }
        mainVC!.startCoordinate = locValue
//        mainVC!.sceneView.session.setWorldOrigin(relativeTransform: )
    }
    
    @objc func goToDetailsView() {
        returnToMapView()
        mainVC!.arView.session.pause()
        mainVC!.arView.scene.anchors.removeAll()
        
        mainVC?.areDirectionsEnabled = false
        mainVC?.locationManager.stopUpdatingLocation()
        
        mainVC?.directionsBar.removeFromSuperview()
        mainVC?.view.removeConstraints((mainVC?.directionsBarContraints)!)
        
        mainVC?.view.addSubview(mainVC!.locationBar)
        NSLayoutConstraint.activate((mainVC?.locationBarConstraints)!)
        
        mainVC?.mapView.removeOverlays((mainVC?.mapView.overlays)!)
        mainVC!.mapView.setRegion(
            MKCoordinateRegion(
                center: (owner?.owner?.currentLocation?.mapItem?.placemark.coordinate)!,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            animated: true
        )
        
        mainVC?.panel.removePanelFromParent(animated: false)
        mainVC?.setSearchPanel()
        mainVC?.panel.set(contentViewController: owner?.owner)
        mainVC?.panel.layout = PanelPortraitLayout()
        mainVC?.panel.move(to: .half, animated: true)
    }
    
    @objc func viewInAR() {
        UIView.animate(withDuration: 0.5, animations: { [self] in
            mainVC!.mapView.alpha = 0
            mainVC!.arView.alpha = 1
        })
        
        viewInARButton.removeFromSuperview()
        view.removeConstraints(viewInARButtonContraints!)
        
        mapViewButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapViewButton)
        NSLayoutConstraint.activate(mapViewButtonConstraints!)
        
        mapViewButton.addTarget(self, action: #selector(returnToMapView), for: .touchUpInside)
    }
    
    @objc func returnToMapView() {
        UIView.animate(withDuration: 0.5, animations: { [self] in
            mainVC!.mapView.alpha = 1
            mainVC!.arView.alpha = 0
        })
        
        mapViewButton.removeFromSuperview()
        view.removeConstraints(mapViewButtonConstraints!)
        
        view.addSubview(viewInARButton)
        NSLayoutConstraint.activate(viewInARButtonContraints!)
    }
}
