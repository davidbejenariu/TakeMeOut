//
//  ARSessionHelper.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 31.05.2023.
//

import Foundation
import CoreLocation
import ARKit
import RealityKit
import MapKit

extension MainViewController {
    func addAnchor(at position: SIMD3<Float>) {
        let innerSphere = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 0.66),
            materials: [UnlitMaterial(color: #colorLiteral(red: 0, green: 0.3, blue: 1.4, alpha: 1))]
        )
        let outerSphere = ModelEntity(
            mesh: MeshResource.generateSphere(radius: 1),
            materials: [SimpleMaterial(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.25), roughness: 0.3, isMetallic: true)]
        )
        let anchor = AnchorEntity(world: position)
        let headingInRadians = degreesToRadians(degrees: deviceHeading!)
        
        anchor.transform.matrix.columns.3.y = Float(headingInRadians)
//        anchor.transform.matrix.columns.0.x = Float(cos(deviceHeading!))
//        anchor.transform.matrix.columns.0.z = Float(sin(deviceHeading!))
//        anchor.transform.matrix.columns.2.x = Float(-1 * sin(deviceHeading!))
//        anchor.transform.matrix.columns.2.z = Float(cos(deviceHeading!))
        
        anchor.addChild(innerSphere)
        anchor.addChild(outerSphere)
        
        arView.scene.addAnchor(anchor)
    }
    
    func interpolatePoints(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        var points: [CLLocationCoordinate2D] = []
        let distance = CLLocation(latitude: start.latitude, longitude: start.longitude).distance(from: CLLocation(latitude: end.latitude, longitude: end.longitude))
        let count = Int(distance / 15.0)

        for i in 0...count {
            let fraction = Double(i) / Double(count)
            let lon = start.longitude + (end.longitude - start.longitude) * fraction
            let lat = start.latitude + (end.latitude - start.latitude) * fraction
            
            points.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }

        return points
    }
    
    func getRelativePosition(from startCoordinate: CLLocationCoordinate2D, to endCoordinate: CLLocationCoordinate2D) -> SIMD3<Float> {
        let distance = haversineDistance(lat1: startCoordinate.latitude, lon1: startCoordinate.longitude, lat2: endCoordinate.latitude, lon2: endCoordinate.longitude) * 1000 // distance in meters
        let bearing = calculateBearing(from: startCoordinate, to: endCoordinate) // bearing in radians
        
        let z = -Float(distance * cos(bearing)) // forward/backward direction (negative because in ARKit, negative Z is "forward")
        let x = Float(distance * sin(bearing)) // left/right direction
        
        return SIMD3<Float>(x, 0, z) // we keep y as 0 for simplicity (assuming no elevation change)
    }
    
//    func adjustPositionWithCorrectionAngle(position: simd_float3, correctionAngle: Float) -> simd_float3 {
//        // Create a rotation matrix that represents a rotation around the y-axis by the correction angle
//        let rotationMatrix = float4x4(SCNMatrix4MakeRotation(correctionAngle, 0, 1, 0))
//
//        // Rotate the position by the correction angle
//        let adjustedPosition = simd_make_float3(rotationMatrix * simd_float4(position, 1))
//
//        return adjustedPosition
//    }
    
    func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let radiusEarthKilometers = 6371.0
        let diffLat = degreesToRadians(degrees: lat2 - lat1)
        let diffLon = degreesToRadians(degrees: lon2 - lon1)
        
        let a = sin(diffLat / 2) * sin(diffLat / 2) +
            cos(degreesToRadians(degrees: lat1)) *
            cos(degreesToRadians(degrees: lat2)) *
            sin(diffLon / 2) * sin(diffLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        return radiusEarthKilometers * c
    }
    
    func calculateBearing(from startCoordinate: CLLocationCoordinate2D, to endCoordinate: CLLocationCoordinate2D) -> Double {
        let lat1 = degreesToRadians(degrees: startCoordinate.latitude)
        let lon1 = startCoordinate.longitude
        
        let lat2 = degreesToRadians(degrees: endCoordinate.latitude)
        let lon2 = endCoordinate.longitude
        
        let dLon = degreesToRadians(degrees: lon2 - lon1)
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var bearing = atan2(y, x)
        
        // Convert to degrees and adjust value to 0-360
        bearing = radiansToDegrees(radians: bearing)
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)
        
        // Convert back to radians
        bearing = degreesToRadians(degrees: bearing)
        
        return bearing
    }
    
//    func getCorrectionAngle() -> Float {
//        return Float(deviceHeading!) - getCameraRotation()
//    }
//
//    func getCameraRotation() -> Float {
//        guard let frame = arView.session.currentFrame else { return 0 }
//
//        let cameraTransform = frame.camera.transform
//        let cameraRotation = simd_quaternion(cameraTransform) // create a quaternion from the transform matrix
//        let cameraYRotation = asin(cameraRotation.imag.y) // extract the y-axis rotation in radians
//
//        return cameraYRotation
//    }

    func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180
    }

    func radiansToDegrees(radians: Double) -> Double {
        return radians * 180 / .pi
    }
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: self.pointCount)
        self.getCoordinates(&coords, range: NSRange(location: 0, length: self.pointCount))
        return coords
    }
}
