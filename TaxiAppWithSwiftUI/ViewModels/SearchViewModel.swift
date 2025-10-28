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
    
    /**
         指定された検索語と地図の範囲に基づいて、非同期で施設検索を実行

         - Parameters:
            - searchText: 検索するキーワード（例: "カフェ"）。
            - center: 検索範囲の中心となる地図上の座標。
            - meters: 中心座標からの検索範囲（メートル単位）。
     */
    func searchPlace(searchText: String, center: CLLocationCoordinate2D, meters: CLLocationDistance) async {
        // 検索条件を格納するためのリクエストオブジェクトを生成
        let request = MKLocalSearch.Request()
                
        // 検索キーワード（自然言語クエリ）を設定
        request.naturalLanguageQuery = searchText
                
        // 検索を行う地図上の範囲（リージョン）を設定
        request.region = MKCoordinateRegion(center: center, latitudinalMeters: meters, longitudinalMeters: meters)
        
        do {
            
            let results = try await MKLocalSearch(request: request).start()
            
            // 検索結果のMKMapItemリストを、Viewに通知されるプロパティに代入
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


