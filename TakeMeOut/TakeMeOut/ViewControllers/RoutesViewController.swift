//
//  RoutesViewController.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 24.05.2023.
//

import UIKit
import MapKit

class RoutesViewController: UIViewController {
    var routes: [MKRoute] = []
    var owner: DetailsViewController?
    var mainVC: MainViewController?
    var directionsVC: DirectionsViewController?
    
    let closeButton: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(systemName: "xmark.circle.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray])
        config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 30)))
        imageView.preferredSymbolConfiguration = config
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Directions"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let routesTable: UITableView = {
        let tableView = UITableView()
        
        tableView.backgroundColor = .secondarySystemBackground
        tableView.layer.cornerRadius = 10
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(RouteTableViewCell.self, forCellReuseIdentifier: "RouteTableViewCell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .tertiarySystemBackground
        
        mainVC?.panel.surfaceView.grabberHandle.removeFromSuperview()
        mainVC?.panel.layout = PanelToHalfLayout()
        
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(routesTable)
        
        routesTable.delegate = self
        routesTable.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissRoutes)
        )
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        titleLabel.frame = CGRect(x: 20, y: 20, width: view.frame.size.width / 1.3, height: (titleLabel.text?.height(withConstrainedWidth: titleLabel.frame.width, font: titleLabel.font))!)
        
        closeButton.frame = CGRect(x: view.frame.width - 50, y: 20, width: 30, height: 30)
        
        let tableY: CGFloat = titleLabel.frame.origin.y + titleLabel.frame.size.height + 20
        routesTable.frame = CGRect(x: 20, y: tableY, width: view.frame.size.width - 40, height: min(220, CGFloat(routesTable.numberOfRows(inSection: 0)) * 110))
        // CGFloat(routesTable.numberOfRows(inSection: 0)) * routesTable.rowHeight
    }
    
    @objc func dismissRoutes() {
        mainVC?.panel.removePanelFromParent(animated: false)
        mainVC?.setSearchPanel()
        mainVC?.panel.layout = PanelPortraitLayout()
        mainVC?.panel.set(contentViewController: owner!)
        mainVC?.panel.move(to: .half, animated: false)
        
        mainVC!.mapView.removeOverlays((mainVC!.mapView.overlays))
        mainVC!.mapView.setRegion(
            MKCoordinateRegion(
                center: (owner!.currentLocation?.mapItem?.placemark.coordinate)!,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            animated: true
        )
    }
    
    @objc func getWalkingDirections(_ sender: UIButton) {
        let index = sender.tag
        
        directionsVC = DirectionsViewController()
        directionsVC?.owner = self
        directionsVC?.mainVC = mainVC
        directionsVC?.route = routes[index]
        directionsVC?.titleLabel.text = "Walking to \(owner?.currentLocation?.mapItem?.name ?? "Selected Location")"
        
        mainVC?.selectedPolyline = routes[index].polyline
        mainVC?.routeDistance = routes[index].distance
        
        mainVC?.panel.layout = PanelToTipLayout()
        mainVC?.panel.set(contentViewController: directionsVC)
        mainVC?.panel.move(to: .tip, animated: true)
    }
}

extension RoutesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(routes.count, 3)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RouteTableViewCell", for: indexPath) as? RouteTableViewCell {
            let timeLabel = cell.routeData.subviews[0] as! UILabel
            let time = routes[indexPath.row].expectedTravelTime / 60
            
            if time < 60 {
                timeLabel.text = "\(Int(time)) min"
            } else {
                timeLabel.text = "\(Int(time / 60)) hr \((Int(time.truncatingRemainder(dividingBy: 60)))) min"
            }
            
            let distanceLabel = cell.routeData.subviews[1] as! UILabel
            let distance = routes[indexPath.row].distance
            
            if distance < 1000 {
                distanceLabel.text = "\(Int(distance)) m"
            } else {
                distanceLabel.text = String(format: "%.1f km", distance / 1000)
            }
            
            let advisoryNotices = routes[indexPath.row].advisoryNotices
            
            if !advisoryNotices.isEmpty {
                distanceLabel.text! += " · \(String(describing: advisoryNotices.first))"
            }
            
            cell.goButton.tag = indexPath.row
            cell.goButton.addTarget(self, action: #selector(getWalkingDirections(_ :)), for: .touchUpInside)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // deselect the previous polyline
        if mainVC?.selectedPolyline != nil {
            let renderer = mainVC?.mapView.renderer(for: (mainVC?.selectedPolyline)!) as? MKPolylineRenderer
            renderer?.strokeColor = .systemMint
        }
        
        mainVC?.selectedPolyline = routes[indexPath.row].polyline
        
        // select the new polyline
        mainVC?.mapView.removeOverlay(routes[indexPath.row].polyline)
        mainVC?.mapView.addOverlay(routes[indexPath.row].polyline)
        
        let renderer = mainVC?.mapView.renderer(for: routes[indexPath.row].polyline) as? MKPolylineRenderer
        renderer?.setNeedsDisplay()
    }
}
