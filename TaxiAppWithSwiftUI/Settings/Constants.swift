//
//  Constants.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/11/05.
//

import Foundation
import CoreLocation

struct Constants {
    /// ルート表示時の境界矩形に追加するパディングの比率
    static let paddingRatio = 0.2
    
    /// informationエリアの高さ（ポイント）
    static let informationAreaHeight: CGFloat = 240
    
    /// プレビュー用のサンプル座標
    static let sampleCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917)
    
    /// 目的地の検索範囲（メートル単位）
    static let searchRegion: CLLocationDistance = 1000
    
    /// 目的地表示時のカメラ距離（メートル単位）
    static let cameraDistance: Double = 1000
    
    /// 地図上のピンアイコンの高さ（ポイント）
    static let pinHeight: CGFloat = 40
    
}
