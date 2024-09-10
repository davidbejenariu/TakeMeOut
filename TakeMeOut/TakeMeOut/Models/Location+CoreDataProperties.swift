//
//  Location+CoreDataProperties.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 15.05.2023.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var category: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var savedBy: User?

}

extension Location : Identifiable {

}
