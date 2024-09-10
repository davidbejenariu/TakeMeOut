//
//  CategoriesHelper.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 18.05.2023.
//

import Foundation
import MapKit

// MARK: TODO add colours

var categoryOf: [String: String] = [
    MKPointOfInterestCategory.airport.rawValue: "Airport",
    MKPointOfInterestCategory.amusementPark.rawValue: "Amusement Park",
    MKPointOfInterestCategory.aquarium.rawValue: "Aquarium",
    MKPointOfInterestCategory.atm.rawValue: "ATM",
    MKPointOfInterestCategory.bakery.rawValue: "Bakery",
    MKPointOfInterestCategory.bank.rawValue: "Bank",
    MKPointOfInterestCategory.beach.rawValue: "Beach",
    MKPointOfInterestCategory.brewery.rawValue: "Brewery",
    MKPointOfInterestCategory.cafe.rawValue: "Cafe",
    MKPointOfInterestCategory.campground.rawValue: "Campground",
    MKPointOfInterestCategory.carRental.rawValue: "Car Rental",
    MKPointOfInterestCategory.evCharger.rawValue: "EV Charger",
    MKPointOfInterestCategory.fireStation.rawValue: "Fire Station",
    MKPointOfInterestCategory.fitnessCenter.rawValue: "Fitness Centre",
    MKPointOfInterestCategory.foodMarket.rawValue: "Food Market",
    MKPointOfInterestCategory.gasStation.rawValue: "Gas Station",
    MKPointOfInterestCategory.hospital.rawValue: "Hospital",
    MKPointOfInterestCategory.hotel.rawValue: "Hotel",
    MKPointOfInterestCategory.laundry.rawValue: "Laundry",
    MKPointOfInterestCategory.library.rawValue: "Library",
    MKPointOfInterestCategory.marina.rawValue: "Marina",
    MKPointOfInterestCategory.movieTheater.rawValue: "Movie Theatre",
    MKPointOfInterestCategory.museum.rawValue: "Museum",
    MKPointOfInterestCategory.nationalPark.rawValue: "National Park",
    MKPointOfInterestCategory.nightlife.rawValue: "Night Life",
    MKPointOfInterestCategory.park.rawValue: "Park",
    MKPointOfInterestCategory.parking.rawValue: "Parking",
    MKPointOfInterestCategory.pharmacy.rawValue: "Pharmacy",
    MKPointOfInterestCategory.police.rawValue: "Police",
    MKPointOfInterestCategory.postOffice.rawValue: "Post Office",
    MKPointOfInterestCategory.publicTransport.rawValue: "Public Transport",
    MKPointOfInterestCategory.restaurant.rawValue: "Restaurant",
    MKPointOfInterestCategory.restroom.rawValue: "Restroom",
    MKPointOfInterestCategory.school.rawValue: "School",
    MKPointOfInterestCategory.stadium.rawValue: "Stadium",
    MKPointOfInterestCategory.store.rawValue: "Store",
    MKPointOfInterestCategory.theater.rawValue: "Theatre",
    MKPointOfInterestCategory.university.rawValue: "University",
    MKPointOfInterestCategory.zoo.rawValue: "Zoo",
    "none": "none"
]

var iconFor: [String: String] = [
    "Airport": "airplane.circle.fill",
    "Amusement Park": "location.circle.fill",
    "Aquarium": "fish.circle.fill",
    "ATM": "creditcard.circle.fill",
    "Bakery": "location.circle.fill",
    "Bank": "building.columns.circle.fill",
    "Beach": "sun.haze.circle.fill",
    "Brewery": "fork.knife.circle.fill",
    "Cafe": "fork.knife.circle.fill",
    "Campground": "tent.circle.fill",
    "Car Rental": "car.circle.fill",
    "EV Charger": "bolt.car.circle.fill",
    "Fire Station": "flame.circle.fill",
    "Fitness Centre": "figure.run.circle.fill",
    "Food Market": "cart.circle.fill",
    "Gas Station": "location.circle.fill",
    "Hospital": "cross.case.circle.fill",
    "Hotel": "bed.double.circle.fill",
    "Laundry": "drop.circle.fill",
    "Library": "book.closed.circle.fill",
    "Marina": "sailboat.circle.fill",
    "Movie Theatre": "popcorn.circle.fill",
    "Museum": "building.columns.circle.fill",
    "National Park": "mountain.2.circle.fill",
    "Night Life": "moon.circle.fill",
    "Park": "tree.circle.fill",
    "Parking": "parkingsign.circle.fill",
    "Pharmacy": "pill.circle.fill",
    "Police": "archivebox.circle.fill",
    "Post Office": "envelope.circle.fill",
    "Public Transport": "tram.circle.fill",
    "Restaurant": "fork.knife.circle.fill",
    "Restroom": "toilet.circle.fill",
    "School": "backpack.circle.fill",
    "Stadium": "sportscourt.circle.fill",
    "Store": "cart.circle.fill",
    "Theatre": "theatermasks.circle.fill",
    "University": "graduationcap.circle.fill",
    "Zoo": "pawprint.circle.fill"
]
