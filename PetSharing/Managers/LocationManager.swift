//
//  LocationManager.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/2/17.
//

import Foundation
import CoreLocation

class LocationMagager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationMagager()
    let manager = CLLocationManager()
    var completion:((CLLocation) -> Void)?
    
    public func getUserLocation(completion:@escaping ((CLLocation) -> Void)){
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    public func resolveLocationName(with location:CLLocation,completion: @escaping ((String?) -> Void)) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "zh_Hans_CN")) { placemarks, error in
            guard let place = placemarks?.first, error == nil else {
                completion(nil)
                return
            }
            print("place:\(place)")
            var name = ""
            if let adminRegion = place.administrativeArea {
                name += adminRegion
            }
            if let locality = place.name {
                name += ",\(locality)"
            }
            if let street = place.thoroughfare{
                name += ",\(street)"
            }
            completion(name)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        completion?(location)
        manager.stopUpdatingLocation()
    }
    
}
