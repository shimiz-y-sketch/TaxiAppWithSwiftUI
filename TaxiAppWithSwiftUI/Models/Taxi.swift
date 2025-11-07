//
//  Taxi.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/11/06.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct Taxi: Identifiable, Decodable  {
    /// タクシーを一意に識別するためのID
    let id: String
    /// タクシーの車両番号
    let number: String
    /// Firestoreから取得した緯度・経度情報を保持するプロパティ。
    /// Decodableに準拠しているGeoPoint型として定義する。
    var geoPoint: GeoPoint
    /// タクシーの現在の状態（空車、乗車地へ移動中など）
    var state: TaxiState
    
    /// タクシーの現在の緯度・経度座標
    var coordinates: CLLocationCoordinate2D {
        // GeoPointプロパティの値を利用して、MapKitやCoreLocationで利用可能な
        // CLLocationCoordinate2D型へ変換し、返す計算プロパティ。
        CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
    }
}

enum TaxiState: String, Decodable {
    // 空車状態
    case empty
    /// 乗車地へ向かっている状態
    case goingToRidePoint
}


// 開発用モックデータ
extension Taxi {
    
    static var mocks: [Self] {
        [
            Taxi(
                id: "1",
                number: "111-111",
                geoPoint: .init(latitude: 34.695301, longitude: 135.511417),
                state: .empty
            ),
            Taxi(
                id: "2",
                number: "222-222",
                geoPoint: .init(latitude: 34.710001, longitude: 135.500417),
                state: .empty
            ),
            Taxi(
                id: "3",
                number: "333-333",
                geoPoint: .init(latitude: 34.705301, longitude: 135.497417),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "4",
                number: "444-444",
                geoPoint: .init(latitude: 34.697301, longitude: 135.508417),
                state: .empty
            ),
            Taxi(
                id: "5",
                number: "555-555",
                geoPoint: .init(latitude: 34.710301, longitude: 135.504417),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "6",
                number: "666-666",
                geoPoint: .init(latitude: 34.700301, longitude: 135.498417),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "7",
                number: "777-777",
                geoPoint: .init(latitude: 34.706301, longitude: 135.510417),
                state: .empty
            ),
            Taxi(
                id: "8",
                number: "888-888",
                geoPoint: .init(latitude: 34.703301, longitude: 135.511417),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "9",
                number: "999-999",
                geoPoint: .init(latitude: 34.707301, longitude: 135.499417),
                state: .empty
            )
        ]
    }
}


