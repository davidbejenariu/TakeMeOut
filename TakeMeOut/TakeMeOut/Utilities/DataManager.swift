//
//  DataManager.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 15.05.2023.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DbModel")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()

    // Core Data Saving support
    func save() {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func user(fullName: String, email: String) -> User {
        let user = User(context: persistentContainer.viewContext)
        
        user.fullName = fullName
        user.email = email
        
        return user
    }
    
    func location(name: String, latitude: Double, longitude: Double, category: String, address: String, user: User) -> Location {
        let location = Location(context: persistentContainer.viewContext)
        
        location.name = name
        location.latitude = latitude
        location.longitude = longitude
        location.category = category
        location.address = address
        location.savedBy = user
        
        user.addToSavedLocations(location)
        return location
    }
    
    func updateProfileImage(profileImage: Data, user: User) {
        user.profileImage = profileImage
        save()
    }
    
    func getUsers() -> [User] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        var fetchedUsers: [User] = []
        
        do {
            fetchedUsers = try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error)
        }
        
        return fetchedUsers
    }
    
    func getUser(email: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "email = %@", email)
        var fetchedUser: [User] = []
        
        do {
            fetchedUser = try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error)
        }
        
        if fetchedUser.isEmpty {
            return nil
        } else {
            return fetchedUser[0]
        }
    }
    
    func getLocations(user: User) -> [Location] {
        let request: NSFetchRequest<Location> = Location.fetchRequest()
        request.predicate = NSPredicate(format: "savedBy = %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        var fetchedLocations: [Location] = []
        
        do {
            fetchedLocations = try persistentContainer.viewContext.fetch(request)
        } catch {
            print(error)
        }
        
        return fetchedLocations
    }
    
    // MARK: should delete all user saved location before user deletion
    func deleteUser(user: User) {
        let context = persistentContainer.viewContext
        context.delete(user)
        save()
    }
    
    func deleteLocation(location: Location) {
        let context = persistentContainer.viewContext
        context.delete(location)
        save()
    }
    
    func deleteAllUsers() {
        let users = getUsers()
        
        for user in users {
            deleteUser(user: user)
        }
    }
}
