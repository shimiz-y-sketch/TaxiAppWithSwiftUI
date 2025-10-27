//
//  MainViewModel.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/24.
//

import Foundation
import MapKit
import Combine

class MainViewModel: ObservableObject {
    
    @Published var strPointName = ""
    
    init () {

        Task {
            await getLocationAddress(latitude: 34.6894362, longitude: 135.4963352)
        }
    }
    
    func getLocationAddress(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async {

        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            guard let placemark = placemarks.first else { return }
            
            let administrativeArea = placemark.administrativeArea ?? ""
            let locality = placemark.locality ?? ""
            let subLocality = placemark.subLocality ?? ""
            let throughfare = placemark.thoroughfare ?? ""
            let subThroughfare = placemark.subThoroughfare ?? ""
            
            strPointName = "\(administrativeArea)\(locality)\(subLocality)\(throughfare)\(subThroughfare)"
            
        } catch {
            print("位置情報の処理に失敗：\(error.localizedDescription)")
        }
    }
}
