//
//  CLLocationCoordinate2DExt.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/11/05.
//

import Foundation
import CoreLocation
import MapKit

/// CLLocationCoordinate2D（緯度・経度）に拡張機能を追加
extension CLLocationCoordinate2D {
    
    ///
    /// - Returns: 取得した住所文字列。失敗した場合は空文字列。
    func getLocationAddress() async -> String {
        
        // ジオコーディング（位置情報から地名への変換）を行うためのCLGeocoderインスタンスを生成
        let geocoder = CLGeocoder()
        
        do {
            // 緯度・経度からCLLocationオブジェクトを生成し、逆ジオコーディングを実行
            let placemarks = try await geocoder.reverseGeocodeLocation(CLLocation(latitude: self.latitude, longitude: self.longitude))
            
            // 取得した地名情報（placemarks）の最初のエントリーが存在するか確認
            guard let placemark = placemarks.first else { return "" }
            // MKPlacemarkを経由して、整形された住所文字列を返す
            return MKPlacemark(placemark: placemark).addressString
            
        } catch {
            // 処理中にエラーが発生した場合、エラーを出力し空文字列を返す
            print("位置情報の処理に失敗：\(error.localizedDescription)")
            return ""
        }
    }
    
    /// 現在の座標と指定された座標の2点を画面に収めるための最適な地図表示領域（MKCoordinateRegion）を計算して返す
    ///
    /// - Parameter to: 画面に含めたいもう一方の座標
    /// - Returns: 2点を含むように計算されたMKCoordinateRegion
    func getRegionTo(_ to: Self) -> MKCoordinateRegion {
        // 1. 乗車地と配車タクシーの現在地の中間地点を計算
        let minPoint = Self(
            latitude: (self.latitude + to.latitude) / 2,
            longitude: (self.longitude + to.longitude) / 2
        )
        // 2. 両地点を画面に収めるのに必要な緯度・経度のスパン（拡大率）を計算
        let span = MKCoordinateSpan(
            // 両地点間の緯度・経度差にマージン（Constants.cameraMargin）を乗じて、両方が表示されるよう調整
            latitudeDelta: abs(self.latitude - to.latitude) * Constants.cameraMargin,
            longitudeDelta: abs(self.longitude - to.longitude) * Constants.cameraMargin
        )
        // 3. 中間地点と計算されたスパンを用いてカメラ位置を設定（2点を同時に表示）
        return MKCoordinateRegion(center: minPoint, span: span)
    }
    
}

