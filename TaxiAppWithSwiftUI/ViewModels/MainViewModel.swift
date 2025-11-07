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
import FirebaseFirestore



class MainViewModel: ObservableObject {
    
    @Published var currentUser = User.mock
    
    @Published var showSearchView = false
    
    @Published var ridePointAddress: String?
    var ridePointCoordinates: CLLocationCoordinate2D?
    
    @Published var destinationAddress: String?
    var destinationCoordinates: CLLocationCoordinate2D?
    
    @Published var mainCamera: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @Published var route: MKRoute?
    
    @Published var taxis: [Taxi] = []
    
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
        
        switch currentUser.state {
            
        case .confirming:
            // 1. ルートのポリラインが存在し、その境界矩形（Bounding Map Rect）が取得できるか確認
            guard var rect = route?.polyline.boundingMapRect else { return }
            // 2. 境界矩形の幅と高さに対して、それぞれpaddingRatioのパディングサイズを計算
            let paddingWidth = rect.size.width * Constants.paddingRatio
            let paddingHeight = rect.size.height * Constants.paddingRatio
            // 3. 矩形のサイズをパディング分だけ拡大
            rect.size.width += paddingWidth
            rect.size.height += paddingHeight
            // 4. 拡大した矩形の中心が変わらないように、原点（左上隅）を調整する
            //    幅のパディングを左右均等に割り振るため、原点X座標を paddingWidth / 2 だけ左にずらす
            rect.origin.x -= paddingWidth / 2
            rect.origin.y -= paddingHeight / 2
            // 5. 調整済みの矩形（ルート全体と余白を含む領域）に合わせてカメラ位置を設定
            mainCamera = .rect(rect)
            
        default :
            mainCamera = .userLocation(fallback: .automatic)
        }
        
    }
    
    /// Firestoreからタクシー車両のデータを非同期で取得する
    func fetchTaxis() async {
        
        // Firestoreデータベースのインスタンスを定数として取得
        let firestore = Firestore.firestore()
        
        do {
            // "taxis" という名前のコレクションから全てのドキュメントを取得する。
            // 取得したデータはクエリのスナップショット (QuerySnapshot型) として `snapshot` 変数で受ける。
            let snapshot = try await firestore.collection("taxis").getDocuments()
            
            for document in snapshot.documents {
                // ドキュメントのデータ（辞書形式）を、
                // Decodableに準拠した Swiftの Taxi 型のインスタンスに変換（デコード）する。
                // 変換後の Taxi インスタンスは `taxi` 定数で受ける。
                let taxi = try document.data(as: Taxi.self)
                // 変換が成功したタクシーインスタンスを配列に追加
                taxis.append(taxi)
            }
            print("DEBUG: 全タクシーデータ取得完了 => \(taxis)")
            
        } catch {
            print("タクシーのデータの取得に失敗しました：\(error.localizedDescription)")
        }
    }
    
    /// Firestoreの "taxis" コレクションのリアルタイムな変更を監視するためのリスナーを設定する
    func startTaxisListening() {
        
        // Firestoreデータベースのインスタンスを定数として取得
        let firestore = Firestore.firestore()
        
        // firestore.collection("taxis") に対してスナップショットリスナーを設定
        // これにより、データベースのデータが変更されるたびに、
        // 後続のクロージャ（クエリ結果とエラーを受け取る部分）が自動で実行されるようになる。
        firestore.collection("taxis").addSnapshotListener { querySnapshot, error in
            // 1. エラーハンドリング: リスナーの取得またはデータ読み取り中にエラーが発生した場合
            if let error = error {
                print("リスナーの取得に失敗：\(error.localizedDescription)")
                return
            }
            // 2. データ検証: スナップショットがnilでないことを確認（通常はエラー処理で十分だが念のため）
            guard let snapshot = querySnapshot else {
                print("リスナーにデータ無し")
                return
            }
            
            // 3. 変更点の処理: 今回のスナップショットで発生した差分（追加/変更/削除）を一つずつ処理する
            snapshot.documentChanges.forEach { diff in
                // 変更のタイプに応じて処理を分岐
                switch diff.type {
                    
                case .added:
                    print("DEBUG: タクシーのデータが追加されました")
                case .modified:
                    print("DEBUG: タクシーのデータが更新されました")
                case .removed:
                    print("DEBUG: タクシーのデータが削除されました")
                }
            }
        }
        
    }
    
    func reset() {
        // ユーザーの状態を「乗車地設定中」に戻す
        currentUser.state = .setRidePoint
        
        // 乗車地関連の情報をリセット
        ridePointAddress = nil       // 乗車地住所をクリア
        ridePointCoordinates = nil  // 乗車地座標をクリア
        
        // 目的地関連の情報をリセット
        destinationAddress = nil     // 目的地住所をクリア
        destinationCoordinates = nil// 目的地座標をクリア
        
        // ルート情報をクリア
        route = nil                 // 経路情報をクリア
        
        // カメラ位置をユーザーの現在地（または自動）にリセット
        changeCameraPosition()
    }
    
}
