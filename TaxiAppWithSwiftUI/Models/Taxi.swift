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
extension Taxi {
    
    static var mocks: [Self] {
        [
            Taxi(
                id: "1",
                number: "111-111",
                coordinates: .init(latitude: 35.6895, longitude: 139.6917),
                state: .empty
            ),
            Taxi(
                id: "2",
                number: "222-222",
                coordinates: .init(latitude: 35.45762264893872, longitude: 139.6358223085829),
                state: .empty
            ),
            Taxi(
                id: "3",
                number: "333-333",
                coordinates: .init(latitude: 35.4580885544616, longitude: 139.62589837664265),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "4",
                number: "444-444",
                coordinates: .init(latitude: 35.44998327370894, longitude: 139.62716243048024),
                state: .empty
            ),
            Taxi(
                id: "5",
                number: "555-555",
                coordinates: .init(latitude: 35.447348742599324, longitude: 139.63230460286928),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "6",
                number: "666-666",
                coordinates: .init(latitude: 35.455875478531276, longitude: 139.63106053644591),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "7",
                number: "777-777",
                coordinates: .init(latitude: 35.44625371395893, longitude: 139.6392256158568),
                state: .empty
            ),
            Taxi(
                id: "8",
                number: "888-888",
                coordinates: .init(latitude: 35.45429134421111, longitude: 139.63739526634797),
                state: .goingToRidePoint
            ),
            Taxi(
                id: "9",
                number: "999-999",
                coordinates: .init(latitude: 35.44571784300777, longitude: 139.62734263722658),
                state: .empty
            )
        ]
    }
}


