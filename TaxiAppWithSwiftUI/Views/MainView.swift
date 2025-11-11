//
//  MainView.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/22.
//

import SwiftUI
import MapKit

struct MainView: View {
    
    @StateObject var mainViewModel = MainViewModel()
    
    // 書記画面表示用のバインディング変数（固定値）
//    @State private var cameraPosition: MapCameraPosition = .region(
//        MKCoordinateRegion(
//            center: .init(latitude: 35.452183, longitude: 139.632419),
//            latitudinalMeters: 10000,
//            longitudinalMeters: 10000)
    //        )
    
    var body: some View {
        VStack {
            // Map Area
            map
            
            // Information Area
            information
        }
        .alert("確認", isPresented: $mainViewModel.showAlert) {
            Button("OK") {
                
            }
        } message: {
            Text("タクシーが乗車地に到着しました")
        }

    }
}

#Preview {
    MainView()
}

extension MainView {
    
    private var map: some View {
        // Map Viewを定義し、カメラ位置を ViewModel の `mainCamera` にバインド
        Map(position: $mainViewModel.mainCamera) {
            
            // User's current location
            // ユーザーの現在地を示す組み込みのアノテーション
            UserAnnotation()
            
            // Taxi Location
            // 条件: ユーザーが乗車地を設定している状態（.setRidePoint）のときのみ表示
            if mainViewModel.currentUser.state == .setRidePoint {
                // ViewModelのタクシー配列を反復処理
                ForEach(mainViewModel.taxis) { taxi in
                    // 条件: タクシーの状態が .empty（空車）の場合のみ表示
                    if taxi.state == .empty {
                        // タクシーの位置にカスタムアノテーションを表示
                        Annotation(taxi.number, coordinate: taxi.coordinates) {
                            Image(systemName: "car.circle.fill")
                        }
                    }
                }
            }
            
            // Route Polyline
            // ユーザーの状態が `.confirming` (ルート確認中) の場合にのみ、ルートの線を表示する
            if mainViewModel.currentUser.state == .confirming {
                // 条件: ViewModelの `route` プロパティにポリラインデータが存在する場合のみ表示
                if let polyline = mainViewModel.route?.polyline {
                    // 取得したポリラインデータをマップ上に描画
                    MapPolyline(polyline)
                    // ルートの線のスタイルを設定
                        .stroke(.blue, lineWidth: 7)
                }
            }
            
            // ユーザーの状態が `.confirming` (ルート確認中) または `.ordered` (配車済み) の場合に、
            // 乗車地と目的地のマーカーを表示する
            if mainViewModel.currentUser.state == .confirming ||
                mainViewModel.currentUser.state == .ordered
            {
                // Ride point and Destination
                // 条件: 乗車地座標と目的地座標の両方が設定されている場合のみ表示
                if let ridePoint = mainViewModel.ridePointCoordinates,
                   let destination = mainViewModel.destinationCoordinates {
                    // 乗車地マーカーを青色で表示
                    Marker("乗車地", coordinate: ridePoint).tint(.blue)
                    // 目的地マーカーを青色で表示
                    Marker("目的地", coordinate: destination).tint(.blue)
                }
            }
            
            // Selected Taxi
            // ユーザーの状態が `.ordered` (配車済み) の時に配車タクシー用マーカーを表示
            if mainViewModel.currentUser.state == .ordered {
                // ViewModelの `selectedTaxi` プロパティ（配車が確定したタクシー）が存在する場合に表示
                if let taxi = mainViewModel.selectedTaxi {
                    
                    // 確定したタクシーの位置にカスタムアノテーションを表示
                    Annotation(taxi.number, coordinate: taxi.coordinates) {
                        Image(systemName: "car.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.main)
                    }
                    
                }
            }
        }
        .overlay {
            if mainViewModel.currentUser.state == .setRidePoint {
                CenterPin()
            }
        }
        
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
            mainViewModel.startTaxisListening()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            if mainViewModel.currentUser.state == .setRidePoint {
                Task {
                    await mainViewModel.setRideLocation(coordinates: context.region.center)
                    print("DEBUG: 逆ジオエンコーティング実行\nUserStateは → \(mainViewModel.currentUser.state)")  // デバッグ用
                }
            }
        }
    }
    
    private var information: some View {
        VStack {
            // Starting Point
            HStack(spacing: 12) {
                Image(systemName: "figure.wave")
                    .imageScale(.large)
                    .foregroundStyle(.main)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("乗車地")
                            .font(.subheadline)
                        Text("地図を動かして地点を調整")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    Text(mainViewModel.ridePointAddress ?? "")
                        .font(.headline)
                    
                }
                Spacer()
            }
            .padding(.vertical)
            
            // Destination
            Destination(address: mainViewModel.destinationAddress)
                .threeTriangles(x: 8, y: -16)
            
            Spacer()
            
            // Button or Status
            // ユーザーの現在の状態に応じて、ボタン群を表示するか、配車ステータスを表示するかを分岐
            
            // 状態が .ordered（配車済み）の場合、進行状況を示す Status View を表示する
            if mainViewModel.currentUser.state == .ordered {
                
                Status()
                
            } else if mainViewModel.currentUser.state == .confirming {
                
                HStack(spacing: 16) {
                    Button {
                        mainViewModel.reset()
                    } label: {
                        Text("キャンセル")
                            .modifier(BasicButton(isPrimary: false))
                    }
                    
                    Button {
                        // ユーザー状態を .ordered（配車済み）に更新し、UIをステータス表示に切り替える
                        mainViewModel.currentUser.state = .ordered
                        
                        Task {
                            await mainViewModel.callATaxi()
                        }
                        
                    } label: {
                        Text("タクシーを呼ぶ")
                            .modifier(BasicButton())
                    }
                }
                
            } else {
                
                Button {
                    // 1. ユーザーの状態を「目的地検索中」に切り替え
                    mainViewModel.currentUser.state = .searchLocation
                    print("UserState変更: \(mainViewModel.currentUser.state)")  // デバッグ用
                    // 2. State変数を切り替えて、.sheet モディファイアによる画面遷移をトリガー
                    mainViewModel.showSearchView.toggle()
                } label: {
                    Text("目的地を指定する")
                        .modifier(BasicButton())
                }
                
                // モーダル画面（SearchView）の表示設定
                // $showSearchViewはモーダルの表示／非表示を管理するBinding<Bool>
                .sheet(isPresented: $mainViewModel.showSearchView) {
                    // 画面（SearchView）が閉じられたときに実行されるコールバック処理
                    
                    // 3. ユーザーの状態を「乗車地設定中」に戻す(← ルート確認画面じゃなければ）
                    if mainViewModel.currentUser.state != .confirming {
                        mainViewModel.currentUser.state = .setRidePoint
                    }
                    print("UserState変更: \(mainViewModel.currentUser.state)")  // デバッグ用
                } content: {
                    // 4. モーダルとして表示するView（検索画面）の定義
                    
                    // 現在の乗車地座標を検索の中心として渡す
                    SearchView()
                    // SearchViewとその子孫ViewでMainViewModelを利用できるように環境に登録
                        .environmentObject(mainViewModel)
                }
                
            }
        }
        .padding(.horizontal)
        .frame(height: Constants.informationAreaHeight)
    }
}
