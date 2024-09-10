//
//  SearchViewController.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 06.05.2023.
//

import UIKit
import CoreLocation
import FloatingPanel
import MapKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ vc: SearchViewController, didSelectLocation location: FavouriteModel)
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: SearchViewControllerDelegate?
    weak var owner: MainViewController?
    var locations: [MKMapItem] = []
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()

        searchBar.placeholder = "Where to?"
        searchBar.barTintColor = .secondarySystemBackground
        searchBar.backgroundImage = UIImage()

        return searchBar
    }()
    
    let favouritesVC = FavouritesViewController()
    
    let tableView: UITableView = {
        let table = UITableView()
        
        table.register(LocationTableViewCell.self, forCellReuseIdentifier: "LocationTableViewCell")
        table.backgroundColor = .tertiarySystemBackground
        table.keyboardDismissMode = .onDrag
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .tertiarySystemBackground
        view.addSubview(searchBar)
        view.addSubview(favouritesVC.view)
        
        searchBar.delegate = self
        favouritesVC.owner = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchBar.sizeToFit()
        searchBar.frame = CGRect(x: 5, y: 10, width: view.frame.size.width - 10, height: searchBar.frame.size.height)
        
        let tableY: CGFloat = searchBar.frame.origin.y + searchBar.frame.size.height + 5
        tableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height)
        
        favouritesVC.view.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            request.region = (owner?.mapView.region)!
            
            let search = MKLocalSearch(request: request)
            search.start { response, _ in
                guard let response = response else {
                    return
                }
                
                self.locations = response.mapItems
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(locations.count, 10)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as? LocationTableViewCell {
            cell.name.text = locations[indexPath.row].name
            cell.name.numberOfLines = 1
            cell.name.lineBreakMode = .byTruncatingTail
            
            let distance = getDistance(locations[indexPath.row])
            
            if locations[indexPath.row].pointOfInterestCategory != nil {
                let category = locations[indexPath.row].pointOfInterestCategory?.rawValue
                
                if categoryOf.keys.contains(category!) {
                    if iconFor.keys.contains(categoryOf[category!]!) {
                        cell.icon.image = UIImage(systemName: iconFor[categoryOf[category!]!]!)
                    } else {
                        cell.icon.image = UIImage(systemName: "location.circle.fill")
                    }
                }
            } else {
                cell.icon.image = UIImage(systemName: "location.circle.fill")
            }
            
            if distance < 1000 {
                cell.address.text = "\(Int(distance)) m · "
            } else {
                cell.address.text = String(format: "%.1f km · ", distance / 1000)
            }
            
            var address = locations[indexPath.row].placemark.description
            if let stopAt = address.firstIndex(of: "@") {
                address = String(address.prefix(upTo: stopAt))
            }
            if let beginAt = address.firstIndex(of: ",") {
                let index = address.distance(from: address.startIndex, to: beginAt) + 2
                cell.address.text! += String(address.suffix(from: address.index(address.startIndex, offsetBy: index)))
            }
            cell.address.numberOfLines = 1
            cell.address.lineBreakMode = .byTruncatingTail
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Notify map controller to show pin at selected place
        let location = locations[indexPath.row]
        delegate?.searchViewController(self, didSelectLocation: FavouriteModel(mapItem: location, address: location.placemark.description, category: location.pointOfInterestCategory?.rawValue))
        
        deactivate(searchBar: searchBar)
    }
    
    func getDistance(_ destinationMapItem: MKMapItem) -> Double {
        guard let locValue: CLLocation = owner?.locationManager.location else {
            return 0
        }
        
        return locValue.distance(from: destinationMapItem.placemark.location!)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func activate(searchBar: UISearchBar) {
        favouritesVC.view.removeFromSuperview()
        view.addSubview(tableView)
        
        searchBar.showsCancelButton = true
//        searchVC.showHeader(animated: true)
//        searchVC.tableView.alpha = 1.0
    }
    func deactivate(searchBar: UISearchBar) {
        locations = []
        tableView.reloadData()
        tableView.removeFromSuperview()
        
        view.addSubview(favouritesVC.view)
        // MARK: TODO recent searches?
        
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text = ""
//        searchVC.hideHeader(animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        deactivate(searchBar: searchBar)
        owner?.panel.move(to: .half, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        activate(searchBar: searchBar)
        owner?.panel.move(to: .full, animated: true)
    }
}
