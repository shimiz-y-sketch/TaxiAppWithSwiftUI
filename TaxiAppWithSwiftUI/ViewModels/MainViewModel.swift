//
//  MainViewModel.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/24.
//

import Foundation
import MapKit
import Combine
import SwiftUI

enum UserState {
    case setRidePoint
    case searchLocation
    case setDestination
    case confirming
}

class MainViewModel: ObservableObject {
    
    var userState: UserState = .setRidePoint {
        didSet {
            print("DEBUG: UserState is \(userState)")
        }
    }
    
    @Published var showSearchView = false
    
    @Published var ridePointAddress: String?
    var ridePointCoordinates: CLLocationCoordinate2D?
    
    @Published var destinationAddress: String?
    var destinationCoordinates: CLLocationCoordinate2D?
    
    @Published var mainCamera: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @Published var route: MKRoute?
    
    func setRideLocation(coordinates: CLLocationCoordinate2D) async {
        ridePointCoordinates = coordinates
        ridePointAddress = await coordinates.getLocationAddress()
    }
    
    func setDestination(coordinates: CLLocationCoordinate2D) async {
        destinationCoordinates = coordinates
        destinationAddress = await coordinates.getLocationAddress()
    }
    
    func fetchRoute() async {
        // 1. 値のアンラップ
        guard let ridePointCoordinates = ridePointCoordinates else { return }
        guard let destinationCoordinates = destinationCoordinates else { return }

        // 2. MKPlacemark を明示的に生成
        let sourcePlacemark = MKPlacemark(coordinate: ridePointCoordinates)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates)

        let request = MKDirections.Request()

        // 3. MKMapItem を明示的に生成し、代入
        request.source = MKMapItem(placemark: sourcePlacemark)  //乗車地（スタート）の設定
        request.destination = MKMapItem(placemark: destinationPlacemark)  //目的地（ゴール）の設定
  
        do {
            let directions = try await MKDirections(request: request).calculate()
            route = directions.routes.first
            
            changeCameraPosition()
            
        } catch {
            print("ルートの生成に失敗しました： \(error.localizedDescription)")
        }
    }
    
    private func changeCameraPosition() {
        // 1. ルートのポリラインが存在し、その境界矩形（Bounding Map Rect）が取得できるか確認
        guard var rect = route?.polyline.boundingMapRect else { return }
        // 2. 境界矩形の幅と高さに対して、それぞれ20%のパディングサイズを計算
        let paddingWidth = rect.size.width * 0.2
        let paddingHeight = rect.size.height * 0.2
        // 3. 矩形のサイズをパディング分だけ拡大
        rect.size.width += paddingWidth
        rect.size.height += paddingHeight
        // 4. 拡大した矩形の中心が変わらないように、原点（左上隅）を調整する
        //    幅のパディングを左右均等に割り振るため、原点X座標を paddingWidth / 2 だけ左にずらす
        rect.origin.x -= paddingWidth / 2
        rect.origin.y -= paddingHeight / 2
        // 5. 調整済みの矩形（ルート全体と余白を含む領域）に合わせてカメラ位置を設定
        mainCamera = .rect(rect)
    }
    
    func reset() {
        // ユーザーの状態を「乗車地設定中」に戻す
        userState = .setRidePoint
        
        // 乗車地関連の情報をリセット
        ridePointAddress = ""       // 乗車地住所をクリア
        ridePointCoordinates = nil  // 乗車地座標をクリア
        
        // 目的地関連の情報をリセット
        destinationAddress = ""     // 目的地住所をクリア
        destinationCoordinates = nil// 目的地座標をクリア
        
        // ルート情報をクリア
        route = nil                 // 経路情報をクリア
        
        // カメラ位置をユーザーの現在地（または自動）にリセット
        mainCamera = .userLocation(fallback: .automatic)
    }
}
