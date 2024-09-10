//
//  FavouritesViewController.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 16.05.2023.
//

import UIKit
import MapKit
import CoreData
import FirebaseAuth

class FavouritesViewController: UIViewController {
    weak var owner: SearchViewController?
    var favouriteLocations: [FavouriteModel] = []
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Favourites"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.backgroundColor = .tertiarySystemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(LocationTableViewCell.self, forCellReuseIdentifier: "LocationTableViewCell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .tertiarySystemBackground

        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let tableY: CGFloat = titleLabel.frame.origin.y + titleLabel.frame.size.height + 10
        tableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    func loadFavourites() {
        if Auth.auth().currentUser != nil {
            guard let locValue: CLLocation = owner?.owner?.locationManager.location else {
                return
            }
            
            favouriteLocations = []
            
            let user = DataManager.shared.getUser(email: (Auth.auth().currentUser?.email)!)
            
            if user != nil {
                let locations = DataManager.shared.getLocations(user: user!)
                
                for location in locations {
                    let favouriteLocation = FavouriteModel(
                        mapItem: MKMapItem(
                            placemark: MKPlacemark(
                                coordinate: CLLocationCoordinate2D(
                                    latitude: location.latitude,
                                    longitude: location.longitude
                                )
                            )
                        ),
                        address: location.address,
                        category: location.category
                    )
                    favouriteLocation.mapItem?.name = location.name
                    favouriteLocations.append(favouriteLocation)
                }
                
                favouriteLocations.sort(by: { locValue.distance(from: ($0.mapItem?.placemark.location)!) < locValue.distance(from: ($1.mapItem?.placemark.location)!) })
                
                if favouriteLocations.count == 0 {
                    titleLabel.text = "Your favourite locations will appear here"
                } else {
                    titleLabel.text = "Favourites"
                }
                
                tableView.reloadData()
            }
        }
    }
}

extension FavouritesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell", for: indexPath) as? LocationTableViewCell {
            cell.name.text = favouriteLocations[indexPath.row].mapItem?.name
            cell.name.numberOfLines = 1
            cell.name.lineBreakMode = .byTruncatingTail
            
            let distance = owner?.getDistance(favouriteLocations[indexPath.row].mapItem!)
            let category = favouriteLocations[indexPath.row].category
            
            if categoryOf.keys.contains(category!) {
                if iconFor.keys.contains(categoryOf[category!]!) {
                    cell.icon.image = UIImage(systemName: iconFor[categoryOf[category!]!]!)
                } else {
                    cell.icon.image = UIImage(systemName: "location.circle.fill")
                }
            } else {
                cell.icon.image = UIImage(systemName: "location.circle.fill")
            }
            
            if distance! < 1000 {
                cell.address.text = "\(Int(distance!)) m · "
            } else {
                cell.address.text = String(format: "%.1f km · ", distance! / 1000)
            }
            
//            cell.distance.numberOfLines = 1
//            cell.distance.lineBreakMode = .byTruncatingTail
            
            let address = favouriteLocations[indexPath.row].address!
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
        
        let location = favouriteLocations[indexPath.row]
        owner!.delegate?.searchViewController(owner!, didSelectLocation: location)

        owner!.deactivate(searchBar: owner!.searchBar)
    }
}
