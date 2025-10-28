//
//  SearchViewModel.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/28.
//

import Foundation
import MapKit
import Combine

class SearchViewModel: ObservableObject {
    
    @Published var searchResults: [MKMapItem] = []
    
    init() {
        Task {
            await searchPlace(searchText: "カフェ", center: CLLocationCoordinate2D(latitude: 34.6894362, longitude: 135.4937603), meters: 1000)
        }
        
    }
    
    func searchPlace(searchText: String, center: CLLocationCoordinate2D, meters: CLLocationDistance) async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(center: center, latitudinalMeters: meters, longitudinalMeters: meters)
        
        do {
            
            let results = try await MKLocalSearch(request: request).start()
            searchResults = results.mapItems
            
        } catch {
            
            print("施設検索に失敗しました：\(error.localizedDescription)")
            
        }
    }
    
    func getAddressString(placemark: MKPlacemark) -> String {
        
        let administrativeArea = placemark.administrativeArea ?? ""
        let locality = placemark.locality ?? ""
        let subLocality = placemark.subLocality ?? ""
        let throughfare = placemark.thoroughfare ?? ""
        let subThroughfare = placemark.subThoroughfare ?? ""
        
        return "\(administrativeArea)\(locality)\(subLocality)\(throughfare)\(subThroughfare)"
        
    }
}


