//
//  MainViewModel.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/24.
//

import Foundation
import MapKit
import Combine

enum UserState {
    case setRidePoint
    case searchLocation
}

class MainViewModel: ObservableObject {
    
    var userState: UserState = .setRidePoint
    
    @Published var ridePointName = ""
    var ridePointCoordinates: CLLocationCoordinate2D?
    
    func setRideLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        ridePointCoordinates = location.coordinate
        ridePointName = await getLocationAddress(location: location)
        
    }
      
    /**
     緯度・経度情報に基づいて逆ジオコーディングを実行し、住所文字列を取得してプロパティを更新

     - Parameters:
        - latitude: 検索する地点の緯度。
        - longitude: 検索する地点の経度。
     */
    func getLocationAddress(location: CLLocation) async -> String {

        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            guard let placemark = placemarks.first else { return "" }
            
            let administrativeArea = placemark.administrativeArea ?? ""
            let locality = placemark.locality ?? ""
            let subLocality = placemark.subLocality ?? ""
            let throughfare = placemark.thoroughfare ?? ""
            let subThroughfare = placemark.subThoroughfare ?? ""
            
            return "\(administrativeArea)\(locality)\(subLocality)\(throughfare)\(subThroughfare)"
            
        } catch {
            print("位置情報の処理に失敗：\(error.localizedDescription)")
            return ""
        }
    }
}
