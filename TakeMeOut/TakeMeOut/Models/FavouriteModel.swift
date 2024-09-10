//
//  FavouriteModel.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 16.05.2023.
//

import Foundation
import MapKit

class FavouriteModel {
    let mapItem: MKMapItem?
    let address: String?
    let category: String?
    
    init(mapItem: MKMapItem?, address: String?, category: String?) {
        self.mapItem = mapItem
        self.address = address
        self.category = category
    }
}
