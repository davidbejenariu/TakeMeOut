//
//  User+CoreDataProperties.swift
//  
//
//  Created by David Bejenariu on 02.06.2023.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var fullName: String?
    @NSManaged public var profileImage: Data?
    @NSManaged public var savedLocations: NSSet?

}

// MARK: Generated accessors for savedLocations
extension User {

    @objc(addSavedLocationsObject:)
    @NSManaged public func addToSavedLocations(_ value: Location)

    @objc(removeSavedLocationsObject:)
    @NSManaged public func removeFromSavedLocations(_ value: Location)

    @objc(addSavedLocations:)
    @NSManaged public func addToSavedLocations(_ values: NSSet)

    @objc(removeSavedLocations:)
    @NSManaged public func removeFromSavedLocations(_ values: NSSet)

}
