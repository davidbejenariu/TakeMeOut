//
//  DetailsViewController.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 15.05.2023.
//

import UIKit
import MapKit
import FirebaseAuth
import QuickLook

class DetailsViewController: UIViewController {
    var currentLocation: FavouriteModel?
    var locations = [Location]()
    var foundLocation: Location?
    weak var owner: SearchViewController?
    var routesVC: RoutesViewController?
    let placesManager = PlacesManager()
    
    let scrollView = UIScrollView()
    
    let closeButton: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(systemName: "xmark.circle.fill")
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray])
        config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 30)))
        imageView.preferredSymbolConfiguration = config
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    let distanceView: UIStackView = {
        let view = UIStackView()
        
        let label = UILabel()
        label.text = "Distance"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(paletteColors: [.label])
        config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 20)))
        imageView.preferredSymbolConfiguration = config
        stackView.addSubview(imageView)
        
        let distanceLabel = UILabel()
        distanceLabel.font = .systemFont(ofSize: 18)
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.addSubview(distanceLabel)
        
        view.addSubview(label)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 3),
            stackView.leadingAnchor.constraint(equalTo: label.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: stackView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            distanceLabel.topAnchor.constraint(equalTo: stackView.topAnchor),
            distanceLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5)
        ])
        
        return view
    }()
    
    let hoursView: UIStackView = {
        let view = UIStackView()
        
        let label = UILabel()
        label.text = "Hours"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let hoursLabel = UILabel()
        hoursLabel.text = "Open"
        hoursLabel.font = .systemFont(ofSize: 18)
        hoursLabel.textColor = .systemGreen
        hoursLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(hoursLabel)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hoursLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 3),
            hoursLabel.leadingAnchor.constraint(equalTo: label.leadingAnchor)
        ])
        
        return view
    }()
    
    let imageGallery: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.itemSize = CGSize(width: 300, height: 400)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .tertiarySystemBackground
        
        return collectionView
    }()
    
    let descriptionView: UIStackView = {
        let stackView = UIStackView()
        
        let label = UILabel()
        label.text = "About"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionBox = UIStackView()
        descriptionBox.translatesAutoresizingMaskIntoConstraints = false
        descriptionBox.backgroundColor = .secondarySystemBackground
        descriptionBox.layer.cornerRadius = 10
        descriptionBox.clipsToBounds = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionBox.addSubview(descriptionLabel)
        
        stackView.addSubview(label)
        stackView.addSubview(descriptionBox)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: stackView.topAnchor),
            label.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            descriptionBox.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            descriptionBox.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            descriptionBox.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            descriptionBox.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            descriptionLabel.centerYAnchor.constraint(equalTo: descriptionBox.centerYAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionBox.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionBox.trailingAnchor, constant: -20),
        ])
        
        return stackView
    }()
    
    let detailsLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Details"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    let detailsTable: UITableView = {
        let tableView = UITableView()
        
        tableView.backgroundColor = .secondarySystemBackground
        tableView.layer.cornerRadius = 10
        tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: "DetailTableViewCell")
        
        return tableView
    }()
    
    var locationDetails = LocationDetailsModel()
    
    let directionsButton = CustomButton(labelText: "Get Directions", systemImageName: "figure.walk", buttonColor: .systemMint)
    let addToFavouritesButton = CustomButton(labelText: "Add to Favourites", systemImageName: "star", buttonColor: .systemBlue)
    let removeFromFavouritesButton = CustomButton(labelText: "Remove from Favourites", systemImageName: "star.fill", buttonColor: .systemRed)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesManager.getPlaceDetails(for: (currentLocation?.mapItem?.name)!, with: (currentLocation?.mapItem?.placemark.coordinate)!) { locationDetails in
            self.locationDetails = locationDetails
            
            DispatchQueue.main.async { [self] in
                if !locationDetails.images.isEmpty {
                    imageGallery.reloadData()
                } else {
                    imageGallery.removeFromSuperview()
                }
                
                if locationDetails.isOpenNow != nil {
                    let label = hoursView.subviews[1] as! UILabel
                    label.text = locationDetails.isOpenNow! ? "Open" : "Closed"
                    label.textColor = locationDetails.isOpenNow! ? .systemGreen : .systemRed
                }
                
                if locationDetails.description != nil {
                    let label = descriptionView.subviews[1].subviews[0] as! UILabel
                    label.text = locationDetails.description
                    label.numberOfLines = 0
                    label.lineBreakMode = .byWordWrapping
                    
                    scrollView.addSubview(descriptionView)
                }
                
                detailsTable.reloadData()
                viewDidLayoutSubviews()
            }
        }
        
        view.backgroundColor = .tertiarySystemBackground
        renderFavouriteButton()
        
        scrollView.frame = CGRect(x: 0, y: 20, width: view.frame.size.width, height: view.frame.size.height)
        
        scrollView.addSubview(closeButton)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(addressLabel)
        scrollView.addSubview(hoursView)
        scrollView.addSubview(distanceView)
        scrollView.addSubview(imageGallery)
        scrollView.addSubview(detailsLabel)
        scrollView.addSubview(detailsTable)
        view.addSubview(scrollView)
        
        imageGallery.delegate = self
        imageGallery.dataSource = self
        
        detailsTable.delegate = self
        detailsTable.dataSource = self
        
        if (owner?.getDistance((currentLocation?.mapItem!)!))! < 1000 {
            scrollView.addSubview(directionsButton)
            directionsButton.addTarget(self, action: #selector(renderWalkingDirections), for: .touchUpInside)
        }
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissDetails)
        )
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tapGesture)
        
        titleLabel.text = currentLocation?.mapItem!.name
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        
        var address = currentLocation?.address
        if let stopAt = address!.firstIndex(of: "@") {
            address = String(address!.prefix(upTo: stopAt))
        }
        if let beginAt = address!.firstIndex(of: ",") {
            let index = address!.distance(from: address!.startIndex, to: beginAt) + 2
            addressLabel.text = String(address!.suffix(from: address!.index(address!.startIndex, offsetBy: index)))
        }
        addressLabel.numberOfLines = 0
        addressLabel.lineBreakMode = .byWordWrapping
        
        let distance = owner?.getDistance((currentLocation?.mapItem!)!)
        let label = distanceView.subviews[1].subviews[1] as! UILabel
        
        if distance! < 1000 {
            label.text = "\(Int(distance!)) m"
        } else {
            label.text = String(format: "%.1f km", distance! / 1000)
        }
    }
    
    override func viewDidLayoutSubviews() {
        titleLabel.frame = CGRect(x: 20, y: 0, width: view.frame.size.width / 1.3, height: (titleLabel.text?.height(withConstrainedWidth: titleLabel.frame.width, font: titleLabel.font))!)
        
        closeButton.frame = CGRect(x: view.frame.size.width - 50, y: 0, width: 30, height: 30)

        var labelY = titleLabel.frame.origin.y + titleLabel.frame.size.height + 10
        addressLabel.frame = CGRect(x: 20, y: labelY, width: view.frame.size.width - 40, height: (addressLabel.text?.height(withConstrainedWidth: addressLabel.frame.width, font: addressLabel.font))!)

        let stackY = labelY + addressLabel.frame.size.height + 20
        hoursView.frame = CGRect(x: 20, y: stackY, width: 60, height: 50)
        
        let stackX = hoursView.frame.origin.x + hoursView.frame.size.width + 15
        distanceView.frame = CGRect(x: stackX, y: stackY, width: view.frame.size.width * 0.25, height: 50)
        
        let buttonX = stackX + distanceView.frame.size.width
        directionsButton.frame = CGRect(x: buttonX, y: stackY, width: 195, height: 45)
        
        let collectionY = stackY + distanceView.frame.size.height + 20
        imageGallery.frame = CGRect(x: 0, y: collectionY, width: view.frame.size.width, height: 400)

        labelY = locationDetails.images.isEmpty ? collectionY : collectionY + imageGallery.frame.size.height + 20
        let descriptionLabel = descriptionView.subviews[1].subviews[0] as! UILabel
        let labelHeight = locationDetails.description != nil ? descriptionLabel.text?.height(withConstrainedWidth: descriptionLabel.frame.width, font: descriptionLabel.font) : 0
        descriptionView.frame = CGRect(x: 20, y: labelY, width: view.frame.size.width - 40, height: labelHeight! + 64)
        
        var tableY = locationDetails.description == nil ? labelY + 5 : labelY + descriptionView.frame.size.height + 25
        detailsLabel.frame = CGRect(x: 20, y: tableY, width: 100, height: 25)
        
        tableY += detailsLabel.frame.size.height + 10
        detailsTable.frame = CGRect(x: 20, y: tableY, width: view.frame.size.width - 40, height: 351)
        
        let buttonY = detailsTable.frame.origin.y + detailsTable.frame.size.height + 25
        addToFavouritesButton.frame = CGRect(x: 30, y: buttonY, width: view.frame.size.width - 60, height: 45)
        removeFromFavouritesButton.frame = CGRect(x: 30, y: buttonY, width: view.frame.size.width - 60, height: 45)
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: buttonY + addToFavouritesButton.frame.size.height + 120)
    }
    
    func renderFavouriteButton() {
        if Auth.auth().currentUser != nil {
            let user = DataManager.shared.getUser(email: (Auth.auth().currentUser?.email)!)
            let locations = DataManager.shared.getLocations(user: user!)
            foundLocation = nil
            
            for location in locations {
                if location.latitude == currentLocation?.mapItem!.placemark.coordinate.latitude && location.longitude == currentLocation?.mapItem!.placemark.coordinate.longitude {
                    foundLocation = location
                    break
                }
            }
            
            if foundLocation == nil {
                scrollView.addSubview(addToFavouritesButton)
                addToFavouritesButton.addTarget(self, action: #selector(addToFavourites), for: .touchUpInside)
            } else {
                scrollView.addSubview(removeFromFavouritesButton)
                removeFromFavouritesButton.addTarget(self, action: #selector(removeFromFavourites), for: .touchUpInside)
            }
        }
    }
    
    // MARK: Refactoring - replace owner.owner with mainView, remove pins?
    @objc func dismissDetails() {
        owner?.owner?.panel.move(to: .half, animated: false)
        
        owner?.favouritesVC.loadFavourites()
        owner?.owner?.panel.set(contentViewController: owner!)
        owner?.owner?.updateLocation()
        
//        if owner?.owner?.mapView.overlays != nil {
//            owner?.owner?.mapView.removeOverlays((owner?.owner?.mapView.overlays)!)
//            owner?.owner?.panel.move(to: .half, animated: true)
//        }
    }
    
    @objc func addToFavourites() {
        let currentUser = Auth.auth().currentUser
        
        if currentUser != nil {
            let user = DataManager.shared.getUser(email: (currentUser?.email)!)
            
            if user != nil {
                if let stopAt = currentLocation?.mapItem!.placemark.description.firstIndex(of: "@") {
                    let address = currentLocation?.mapItem!.placemark.description.prefix(upTo: stopAt)
                    
                    let location = DataManager.shared.location(
                        name: (currentLocation?.mapItem!.name)!,
                        latitude: (currentLocation?.mapItem!.placemark.coordinate.latitude)!,
                        longitude: (currentLocation?.mapItem!.placemark.coordinate.longitude)!,
                        category: currentLocation?.category ?? "none",
                        address: String(address!),
                        user: user!
                    )
                    
                    locations.append(location)
                    DataManager.shared.save()
                }
            }
        }
        
        addToFavouritesButton.label.text = "Added to Favourites"
        addToFavouritesButton.image.image = UIImage(systemName: "star.fill")
        addToFavouritesButton.backgroundColor = UIColor(red: 195/255, green: 217/255, blue: 242/255, alpha: 1.0)
        addToFavouritesButton.removeTarget(self, action: #selector(addToFavourites), for: .touchUpInside)
    }
    
    @objc func removeFromFavourites() {
        DataManager.shared.deleteLocation(location: foundLocation!)
        
        removeFromFavouritesButton.label.text = "Removed from Favourites"
        removeFromFavouritesButton.image.image = UIImage(systemName: "star")
        removeFromFavouritesButton.backgroundColor = UIColor(red: 240/255, green: 200/255, blue: 200/255, alpha: 1.0)
        removeFromFavouritesButton.removeTarget(self, action: #selector(removeFromFavourites), for: .touchUpInside)
    }
    
    @objc func renderWalkingDirections() {
        guard let locValue: CLLocationCoordinate2D = owner?.owner?.locationManager.location?.coordinate else {
            return
        }

        let request = MKDirections.Request()
        request.source = MKMapItem(
            placemark: MKPlacemark(coordinate: locValue)
        )
        request.destination = currentLocation?.mapItem
        request.transportType = MKDirectionsTransportType.walking
        request.requestsAlternateRoutes = true

        let directions = MKDirections(request: request)
        directions.calculate { [self] (response, error) in
            guard let response = response else {
                print(error.debugDescription)
                return
            }

            routesVC = RoutesViewController()
            routesVC?.routes = response.routes
            routesVC?.owner = self
            routesVC?.mainVC = owner?.owner!
            
            for route in response.routes {
                owner?.owner?.mapView.addOverlay(route.polyline)
                owner?.owner?.mapView.setVisibleMapRect(
                    route.polyline.boundingMapRect.offsetBy(dx: 0, dy: 500),
                    edgePadding: UIEdgeInsets(top: 120, left: 50, bottom: 320, right: 50),
                    animated: true
                )
            }
            
            owner?.owner?.panel.set(contentViewController: routesVC)
            owner?.owner?.panel.move(to: .half, animated: true)
        }
    }
}

extension DetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationDetails.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        
        if let imageUrl = URL(string: locationDetails.images[indexPath.row]) {
            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                if let error = error {
                    print("Failed fetching image:", error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("Server error")
                    return
                }

                if let data = data {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        } else {
            imageView.image = UIImage(systemName: "person.circle.fill")
        }
        
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        cell.contentView.addSubview(imageView)
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//    }
}

extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var detailLabelText: String = ""
        var infoLabelText: String = ""
        
        if indexPath.row == 0 {
            detailLabelText = "Hours"
            
            if locationDetails.openHours != nil {
                infoLabelText = locationDetails.openHours!
            } else {
                infoLabelText = "Not available"
            }
        } else if indexPath.row == 1 {
            detailLabelText = "Rating"
            
            if locationDetails.rating != nil {
                infoLabelText = "\(locationDetails.rating ?? 10)/10"
            } else {
                infoLabelText = "Not available"
            }
        } else if indexPath.row == 2 {
            detailLabelText = "Popularity"
            
            if locationDetails.popularity != nil {
                infoLabelText = "\(String(format: "%.2f", locationDetails.popularity! * 100))%"
            } else {
                infoLabelText = "Not available"
            }
        } else if indexPath.row == 3 {
            detailLabelText = "Phone"
            
            if locationDetails.phone != nil {
                infoLabelText = locationDetails.phone!
            } else {
                infoLabelText = "Not available"
            }
        } else {
            detailLabelText = "Website"
            
            if locationDetails.website != nil {
                infoLabelText = locationDetails.website!
            } else {
                infoLabelText = "Not available"
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as? DetailTableViewCell {
            cell.infoLabel.text = infoLabelText
            cell.detailLabel.text = detailLabelText
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}
