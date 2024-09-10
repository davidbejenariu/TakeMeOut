//
//  PlacesManager.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 04.06.2023.
//

import Foundation
import GooglePlaces
import CoreLocation

class PlacesManager {
    let apiKey = "fsq3PT/8Oeo6o7apqVhA12+X3SKxkjTQic3uGcDbgjBsrzI="
    
    func getPlaceDetails(for name: String, with coordinate: CLLocationCoordinate2D, completion: @escaping (LocationDetailsModel) -> Void) {
        let details = LocationDetailsModel()
        let headers = [
            "accept": "application/json",
            "Authorization": apiKey
        ]
        
        getPlaceImages(for: name, with: coordinate) { (images, placeId) in
            if placeId == "" {
                completion(details)
            }
            
            if images.isEmpty {
                details.images = []
            }
            
            details.images = images
            
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://api.foursquare.com/v3/places/\(placeId)?fields=description%2Ctel%2Cwebsite%2Chours%2Crating%2Cpopularity")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0
            )
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let error = error {
                    print(error as Any)
                } else if let data = data {
                    do {
                        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                            if jsonResult.keys.contains("description") {
                                details.description = jsonResult["description"] as? String
                            }
                            
                            if jsonResult.keys.contains("hours") {
                                let hours = jsonResult["hours"] as! [String : Any]
                                
                                if hours.keys.contains("display") {
                                    details.openHours = hours["display"] as? String
                                }
                                
                                if hours.keys.contains("open_now") {
                                    details.isOpenNow = "\(hours["open_now"] ?? "")" == "0" ? false : true
                                }
                            }
                            
                            if jsonResult.keys.contains("rating") {
                                details.rating = Double("\(jsonResult["rating"] ?? "")")
                            }
                            
                            if jsonResult.keys.contains("popularity") {
                                details.popularity = Double("\(jsonResult["popularity"] ?? "")")
                            }
                            
                            if jsonResult.keys.contains("tel") {
                                details.phone = jsonResult["tel"] as? String
                            }
                            
                            if jsonResult.keys.contains("website") {
                                details.website = jsonResult["website"] as? String
                            }
                            
                            completion(details)
                        }
                    } catch let error {
                        print("Failed to parse JSON: \(error)")
                    }
                }
            })

            dataTask.resume()
        }
    }
    
    func getPlaceImages(for name: String, with coordinate: CLLocationCoordinate2D, completion: @escaping ([String], String) -> Void) {
        let headers = [
            "accept": "application/json",
            "Authorization": apiKey
        ]

        getPlaceId(for: name, with: coordinate) { (placeId) in
            if placeId == "" {
                completion([], "")
            }
            
            let request = NSMutableURLRequest(
                url: NSURL(string: "https://api.foursquare.com/v3/places/\(placeId)/photos")! as URL,
                cachePolicy: .useProtocolCachePolicy,
                timeoutInterval: 10.0
            )
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers

            let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let error = error {
                    print(error as Any)
                } else if let data = data {
                    do {
                        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                            var imageUrls: [String] = []
                            
                            for nsImageData in jsonResult {
                                if let imageData = nsImageData as? [String : Any] {
                                    imageUrls.append("\(imageData["prefix"] as! String)300x400\(imageData["suffix"] as! String)")
                                }
                            }
                            
                            completion(imageUrls, placeId)
                        }
                    } catch let error {
                        print("Failed to parse JSON: \(error)")
                    }
                }
            })

            dataTask.resume()
        }
    }
    
    func getPlaceId(for name: String, with coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let headers = [
            "accept": "application/json",
            "Authorization": apiKey
        ]
        let convertedName = name.folding(options: .diacriticInsensitive, locale: .current)
        
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://api.foursquare.com/v3/places/search?query=\(convertedName.components(separatedBy: " ").first ?? "")&ll=\(coordinate.latitude)%2C\(coordinate.longitude)&radius=200")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let resultsArray = jsonResult["results"] as? NSArray
                        
                        if resultsArray?.count == 0 {
                            completion("")
                        } else {
                            let result = resultsArray![0] as? [String: Any]
                            completion(result!["fsq_id"] as! String)
                        }
                    }
                } catch let error {
                    print("Failed to parse JSON: \(error)")
                }
            }
        })
        
        dataTask.resume()
    }
}

class GooglePlacesManager {
    let manager = GMSPlacesClient.shared()
    let apiKey = "AIzaSyBFAIiAXcV786NGalG7glhzogeIUEdOA3Q"
    
    func getPlaceId(from coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=5&key=\(apiKey)"
        let url = URL(string: urlString)

        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                // Parse JSON data
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Use jsonResult
                        let resultsArray = jsonResult["results"] as? NSArray
                        let result = resultsArray![1] as? [String: Any]
                        
                        DispatchQueue.main.async {
                            let placeId = (result!["place_id"]! as? String)!
                            completion(placeId)
                        }
                    }
                } catch let error {
                    print("Failed to parse JSON: \(error)")
                }
            }
        }

        task.resume()
    }
    
    func getPlaceDetails(forPlaceWithId placeId: String) {
        let fields: GMSPlaceField = GMSPlaceField(rawValue:
            UInt64(GMSPlaceField.name.rawValue) |
            UInt64(GMSPlaceField.placeID.rawValue)
        )

        manager.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: nil, callback: {
          (place: GMSPlace?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }
          if let place = place {
              print("The selected place is: \(place.name ?? "")")
          }
        })
    }
}
