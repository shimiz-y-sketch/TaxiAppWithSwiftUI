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
    /// タクシーが乗車地に到着したことをユーザーに通知するためのアラートの表示状態
    @Published var showAlertAtRidePoint = false
    /// タクシーが目的地に到着したことをユーザーに通知するためのアラートの表示状態
    @Published var showAlertAtDestination = false
    
    @Published var ridePointAddress: String?
    var ridePointCoordinates: CLLocationCoordinate2D?
    
    @Published var destinationAddress: String?
    var destinationCoordinates: CLLocationCoordinate2D?
    
    @Published var mainCamera: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @Published var route: MKRoute?
    
    @Published var taxis: [Taxi] = []
    /// Firestoreで設定した**全タクシーデータのリアルタイムリスナー**を保持するためのプロパティ。
    /// 配車確定時（callATaxi()実行時）に、このリスナーを停止（remove）するために使用される。
    var taxisListener: ListenerRegistration?
    ///  配車が確定し、ユーザーが現在乗車を待っているタクシーのデータ。
    /// このデータは、マップ上でのタクシーの移動や状態表示に使用される。
    @Published var selectedTaxi: Taxi?
    /// **配車が確定した単一のタクシー**のドキュメントのリアルタイムリスナーを保持するためのプロパティ
    /// タクシーの位置や状態のリアルタイム追跡に使用する
    var selectedTaxiListener: ListenerRegistration?
    
    init() {
        // デバッグ用（タクシー位置・状態の初期化）
        Task {
            await Debug.setTaxi()
        }
    }
    
    func setRideLocation(coordinates: CLLocationCoordinate2D) async {
        ridePointCoordinates = coordinates
        ridePointAddress = await coordinates.getLocationAddress()
    }
    
    func setDestination(coordinates: CLLocationCoordinate2D) async {
        destinationCoordinates = coordinates
        destinationAddress = await coordinates.getLocationAddress()
    }
    /// 乗車地と目的地の間に最適な経路（`MKRoute`）を計算し、結果を `route` プロパティに格納
    /// 経路計算後、`changeCameraPosition()` を呼び出し、マップの表示をルート全体が収まるように自動調整
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
    
    /// Firestoreの "taxis" コレクションのリアルタイムな変更を監視するためのリスナーを設定する
    func listeningForAllTaxis() {
        
        // Firestoreデータベースのインスタンスを定数として取得
        let firestore = Firestore.firestore()
        
        // 配列にデータが重複して追加されるのを防ぐため、既存のローカルデータをクリア
        taxis.removeAll()
        
        // firestore.collection("taxis") に対してスナップショットリスナーを設定
        // これにより、データベースのデータが変更されるたびに、
        // 後続のクロージャ（クエリ結果とエラーを受け取る部分）が自動で実行されるようになる。
        taxisListener = firestore.collection("taxis").addSnapshotListener { querySnapshot, error in
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
                
                // ドキュメントのデータをTaxi型にデコードする処理を do-catch ブロックで実行
                do {
                    // 変更のあったドキュメントを Taxi モデルに変換（デコード）し、`taxi` 定数に格納
                    let taxi = try diff.document.data(as: Taxi.self)
                    
                    // 変更のタイプに応じて処理を分岐 (デコード成功後)
                    switch diff.type {
                        
                    case .added:
                        print("DEBUG: タクシーのデータが追加されました")
                        // ローカルの配列に新しくデコードされた Taxi インスタンスを追加
                        self.taxis.append(taxi)
                        
                    case .modified:
                        print("DEBUG: タクシーのデータが更新されました")
                        // 1. 更新対象の Taxi インスタンスが配列内のどこにあるか、`id` を基にインデックスを検索
                        let index = self.taxis.firstIndex { elem in
                            elem.id == taxi.id
                        }
                        // 2. インデックスが見つかった場合、その位置の要素を新しいデータに置き換える
                        if let index = index {
                            self.taxis[index] = taxi
                        }
                        
                    case .removed:
                        print("DEBUG: タクシーのデータが削除されました")
                        // ローカルの配列から、デコードされた Taxi の `id` と一致する要素を全て削除
                        self.taxis.removeAll { elem in
                            elem.id == taxi.id
                        }
                    }
                    
                } catch {
                    // デコードに失敗した場合、そのエラーを出力する
                    print("Taxi型へのデータ変換に失敗:\(error.localizedDescription)")
                }
                
            }
        }
        
    }
    
    //---------------------------------------------------------
    
    /// 処理内容:
    /// 1. getSelectedTaxiId() を呼び出し、最短距離の空車タクシーのIDを取得する。
    /// 2. 取得したIDに基づき、Firestoreの該当タクシーの状態を「乗車地へ向かう状態」に更新する。
    func callATaxi() async {
        
        // 1. getSelectedTaxiId()を呼び出し、最短タクシーのIDを取得。
        //    IDが取得できなければ（データ不足など）、処理を中断する。
        guard let selectedTaxiId = await getSelectedTaxiId() else { return }
        // 2. Firestoreの該当タクシーの状態を更新:
        await updateTaxiState(id: selectedTaxiId, state: .goingToRidePoint)
        
        taxisListener?.remove()
        
        // 3. 選択したタクシーのドキュメントにリアルタイムリスナーを設定:
        //    タクシーの位置や状態が変更されるたびに、そのデータをリアルタイムで受け取るためのリスナーを設定する
        selectedTaxiListener = Firestore.firestore().collection("taxis").document(selectedTaxiId).addSnapshotListener {
            documentSnapshot, error in
            
            if let error {
                print("配車するタクシーのリスナーの取得に失敗： \(error.localizedDescription) ")
                return
            }
            // データのスナップショットが存在しない場合は処理を中断
            guard let snapshot = documentSnapshot else {
                print("配車するタクシーのリスナーにデータなし")
                return
            }
            
            do {
                // スナップショットから Taxi モデルにデータをデコード
                let taxi = try snapshot.data(as: Taxi.self)
                // デコードしたリアルタイムデータを @Published プロパティに格納し、UIの更新をトリガーする
                self.selectedTaxi = taxi
                
                // 配車後のユーザーの状態に基づいて、カメラの位置を再調整
                self.changeCameraPosition()
                
                // --- タクシー到着検知ロジックを開始 ---
                // 現在のタクシーの状態に応じて処理を分岐
                switch taxi.state {
                    // タクシーがまだ乗車地へ向かっている状態の場合のみ、到着判定を実行する
                case .goingToRidePoint:
                    guard let ridePoint = self.ridePointCoordinates else { return }
                    // 現在のタクシーの位置と乗車地までの直線距離（メートル）を計算。
                    let distance = self.calculateDistance(a: ridePoint, b: taxi.coordinates)
                    print("DEBUG: Distance is \(distance)")
                    // 距離が許容範囲（Constants.meterOfRange）を下回ったか判定し、到着を検知。
                    if distance < Constants.meterOfRange {
                        // タクシーが乗車地に到着したことをFirestoreに非同期で通知する
                        Task {
                            await self.updateTaxiState(id: selectedTaxiId, state: .arrivedAtRidePoint)
                            // アラート表示用の状態変数を更新し、UIに到着を通知する
                            self.showAlertAtRidePoint = true
                        }
                    }
                // TODO
                case .goingToDestination:
                    guard let destination = self.destinationCoordinates else { return }
                    let distance = self.calculateDistance(a: destination, b: taxi.coordinates)
                    if distance < Constants.meterOfRange {
                        
                        Task {
                            await self.updateTaxiState(id: selectedTaxiId, state: .arrivedAtDestination)
                            // アラート表示用の状態変数を更新し、UIに到着を通知する
                            self.showAlertAtDestination = true
                        }
                        
                    }
                    // 上記のケース以外は何もしない
                default:
                    break
                }
                
                // データの受信をデバッグ出力（リアルタイムの動きを確認）
                print("DEBUG: 配車するタクシーのデータ \(taxi)")
            } catch {
                print("タクシーデータの更新に失敗： \(error.localizedDescription)")
            }
        }
    }
    
    func reset() {
        // --- ユーザー状態とUI関連のリセット ---
        // ユーザーの状態を「乗車地設定中」に戻す（アプリの初期操作状態）
        currentUser.state = .setRidePoint
        
        // --- データ関連のリセット ---
        
        // 乗車地関連の情報をリセット
        ridePointAddress = nil      // 乗車地住所をクリア
        ridePointCoordinates = nil  // 乗車地座標をクリア

        // 目的地関連の情報をリセット
        destinationAddress = nil    // 目的地住所をクリア
        destinationCoordinates = nil// 目的地座標をクリア
        
        // ルート情報をクリア
        route = nil                 // 経路情報をクリア
        
        // 配車確定後のタクシー情報をクリア
        selectedTaxi = nil          // 配車が確定したタクシー情報をクリア
        // 追跡中の単一タクシーに対するリアルタイムリスナーを停止
        selectedTaxiListener?.remove()
        
        // --- マップ操作関連のリセット ---
        // カメラ位置をユーザーの現在地（または自動）にリセット
        changeCameraPosition()
        
        // 再度、全空車タクシーのリアルタイム監視を開始
        listeningForAllTaxis()
    }
    
    /// 指定されたIDのタクシーの状態（`TaxiState`）をFirestore上で更新する
    ///
    /// - Parameters:
    ///   - id: 更新対象のタクシーのドキュメントID（`String`）
    ///   - state: 設定したい新しいタクシーの状態（`TaxiState`のrawValue）
    func updateTaxiState(id: String?, state: TaxiState) async {
        // idがnil（未設定）の場合は、処理を中断する
        guard let id else { return }
        
        //デバッグ用
        
        Task {
            await Debug.moveTaxi(id: id, state: state)
        }
        
        do {
            // Firestoreの "taxis" コレクション内の、指定されたIDのドキュメントにアクセス
            try await Firestore.firestore().collection("taxis").document(id).updateData([
                // キーにはフィールドの名前、バリューには保存する値
                // "state" フィールドを新しい状態（state.rawValue）で更新
                "state" : state.rawValue
            ])
        } catch {
            print("タクシーのデータ更新に失敗： \(error.localizedDescription)")
        }
    }
    
}

extension MainViewModel {
    /// ユーザーの状態に応じてマップのカメラ位置を制御
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
            
            // ユーザーが配車済み状態の場合、タクシーの現在の状態に基づいてカメラ位置を制御する
        case .ordered:
            
            // 追跡対象のタクシーデータが存在するか確認
            guard let taxi = selectedTaxi else { return }
            // タクシーの状態が「乗車地へ向かっている」場合
            if taxi.state == .goingToRidePoint {
                // 乗車地座標が存在するか確認
                guard let ridePointCoordinates else { return }
                // タクシーと乗車地の両方を画面に収めるようカメラ位置を設定
                // CLLocationCoordinate2Dの拡張メソッドを使用し、最適な表示領域を計算する
                mainCamera = .region(ridePointCoordinates.getRegionTo(taxi.coordinates))
                
                // タクシーの状態が「目的地へ向かっている」場合（乗車完了後）
            } else if taxi.state == .goingToDestination {
                // 目的地座標が存在するか確認
                guard let destinationCoordinates else { return }
                // タクシーと目的地の両方を画面に収めるようカメラ位置を設定
                mainCamera = .region(destinationCoordinates.getRegionTo(taxi.coordinates))
            }
            
        default :
            mainCamera = .userLocation(fallback: .automatic)
        }
        
    }
    /// Firestoreからタクシー車両のデータを非同期で取得する
    private func fetchTaxis() async -> [Taxi]? {
        // Firestoreデータベースのインスタンスを定数として取得
        let firestore = Firestore.firestore()
        
        do {
            // "taxis" という名前のコレクションから全てのドキュメントを取得する。
            // 取得したデータはクエリのスナップショット (QuerySnapshot型) として `snapshot` 変数で受ける。
            let snapshot = try await firestore.collection("taxis").getDocuments()
            // デコードされた Taxi インスタンスを一時的に保持するための空の配列を宣言
            var tempTaxis: [Taxi] = []
            
            for document in snapshot.documents {
                // ドキュメントのデータ（辞書形式）を、
                // Decodableに準拠した Swiftの Taxi 型のインスタンスに変換（デコード）する。
                // 変換後の Taxi インスタンスは `taxi` 定数で受ける。
                let taxi = try document.data(as: Taxi.self)
                // 変換が成功したタクシーインスタンスを一時配列に追加
                tempTaxis.append(taxi)
            }
            print("DEBUG: tempTaxis => \(tempTaxis)")
            // 全てのドキュメントの処理が完了した後、結果の配列を返す
            return tempTaxis
            
            
        } catch {
            print("タクシーのデータの取得に失敗しました：\(error.localizedDescription)")
            return nil
        }
    }
    // 最短距離の空車タクシーのIDを返すメソッド
    private func getSelectedTaxiId() async -> String? {
        // 1. 必要なデータの安全なアンラップ:
        //    Firestoreから取得した全タクシーデータ (allTaxis) とユーザーが設定した乗車地座標 (ridePointCoordinates) が
        //    取得できなければ、処理を中断し nil を返す。
        guard let allTaxis = await fetchTaxis(),
              let ridePointCoordinates
        else { return nil }
        
        // 2. 乗車地のCLLocationオブジェクトを生成:
        // 最短距離と、そのタクシーのIDを保持するための変数を初期化
        // minDistance: 現在見つかっている最短距離を保持（初期値は無限大）
        var minDistance: CLLocationDistance = .infinity
        // selectedTaxiId: 最短距離のタクシーのIDを保持
        var selectedTaxiId: String?
        
        // 3. 全タクシーを反復処理し、乗車地からの距離を計算・最短を特定する:
        for taxi in allTaxis {
            // guard ステートメントで空車（.empty）でないタクシーをフィルタリング
            // 空車でない場合、continue が実行され、次のタクシーのチェックにスキップされる。
            guard taxi.state == .empty else { continue }
            
            // rideLocation（乗車地）から taxiLocation（タクシー位置）までの
            // 直線距離（メートル単位）を計算
            let distance = calculateDistance(a: ridePointCoordinates, b: taxi.coordinates)
            
            // 距離の比較と最短タクシーの更新
            if distance < minDistance {
                // 現在のタクシーの距離が、記録されている最短距離よりも短ければ以下を実行
                minDistance = distance     // 最短距離をこの距離で更新
                selectedTaxiId = taxi.id   // 最も近いタクシーのIDをこのタクシーで更新
            }
        }
        // DEBUG: 最短タクシーのIDと距離をコンソールに出力
        print("DEBUG:Selected taxi is \(selectedTaxiId ?? "none...") \(minDistance)")
        
        return selectedTaxiId
    }
    /// 2点間の直線距離（メートル）を計算するヘルパーメソッド
    /// - Parameters:
    ///   - a: 1点目の座標 (`CLLocationCoordinate2D`)
    ///   - b: 2点目の座標 (`CLLocationCoordinate2D`)
    /// - Returns: 2点間の距離 (`CLLocationDistance`、メートル単位)
    private func calculateDistance(a: CLLocationCoordinate2D, b: CLLocationCoordinate2D) -> CLLocationDistance {
        
        // CLLocationCoordinate2DをCLLocationオブジェクトに変換
        let locationA = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let locationB = CLLocation(latitude: b.latitude, longitude: b.longitude)
        
        // CLLocationが持つdistance(from:)メソッドで距離を計算
        return locationA.distance(from: locationB)
    }
}
