//
//  Taxi.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/11/06.
//

import Foundation
import CoreLocation

struct Taxi {
        /// タクシーを一意に識別するためのID
        let id: String
        /// タクシーの車両番号
        let number: String
        /// タクシーの現在の緯度・経度座標
        var coordinates: CLLocationCoordinate2D
        /// タクシーの現在の状態（空車、乗車地へ移動中など）
        var state: TaxiState
    
    enum TaxiState {
        // 空車状態
        case empty
        /// 乗車地へ向かっている状態
        case goingToRidePoint
    }
}


// 開発用モックデータ
extension Taxi: Identifiable {
    
    static var mocks: [Self] {
        [
            Taxi(
                id: "1",
                number: "111-111",
                coordinates: .init(latitude: 34.695301, longitude: 135.511417),
                state: .empty
            ),
            Taxi(
                id: "2",
                number: "222-222",
                coordinates: .init(latitude: 34.710001, longitude: 135.500417),
                state: .empty
            ),
            Taxi(
                id: "3",
                number: "333-333",
                coordinates: .init(latitude: 34.705301, longitude: 135.497417),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "4",
                number: "444-444",
                coordinates: .init(latitude: 34.697301, longitude: 135.508417),
                state: .empty
            ),
            Taxi(
                id: "5",
                number: "555-555",
                coordinates: .init(latitude: 34.710301, longitude: 135.504417),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "6",
                number: "666-666",
                coordinates: .init(latitude: 34.700301, longitude: 135.498417),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "7",
                number: "777-777",
                coordinates: .init(latitude: 34.706301, longitude: 135.510417),
                state: .empty
            ),
            Taxi(
                id: "8",
                number: "888-888",
                coordinates: .init(latitude: 34.703301, longitude: 135.511417),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "9",
                number: "999-999",
                coordinates: .init(latitude: 34.707301, longitude: 135.499417),
                state: .empty
            )
        ]
    }
}


