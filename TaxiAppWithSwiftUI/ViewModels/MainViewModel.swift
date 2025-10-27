//
//  MainViewModel.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/24.
//

import Foundation
import MapKit

class MainViewModel {
    
    let strPointName = "横浜市西区みなとみらい1-2"
    
    func getLocationAddress(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            for placemark in placemarks {
                print("placemark:\(placemark)")
            }
            
        } catch {
            print("位置情報の処理に失敗：\(error.localizedDescription)")
        }
    }
}
