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


