//
//  CLLocationCoordinate2DExt.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/11/05.
//

import Foundation
import CoreLocation
import MapKit

extension CLLocationCoordinate2D {
    
  func getLocationAddress() async -> String {

      let geocoder = CLGeocoder()
      
      do {
          let placemarks = try await geocoder.reverseGeocodeLocation(CLLocation(latitude: self.latitude, longitude: self.longitude))
          
          guard let placemark = placemarks.first else { return "" }
          return MKPlacemark(placemark: placemark).addressString
          
      } catch {
          print("位置情報の処理に失敗：\(error.localizedDescription)")
          return ""
      }
  }
    
}

