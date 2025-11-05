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
    }
}

#Preview {
    MainView()
}

extension MainView {
    
    private var map: some View {
        Map(position: $mainViewModel.mainCamera) {
            
            // User's current location
            UserAnnotation()
            
            // Ride point and Destination
            if let ridePoint = mainViewModel.ridePointCoordinates,
               let destination = mainViewModel.destinationCoordinates {
                Marker("乗車地", coordinate: ridePoint).tint(.blue)
                Marker("目的地", coordinate: destination).tint(.blue)
            }
            
            // Route Polyline
            if let polyline = mainViewModel.route?.polyline {
                MapPolyline(polyline)
                    .stroke(.blue, lineWidth: 7)
            }
        }
        .overlay {
            if mainViewModel.userState == .setRidePoint {
                CenterPin()
            }
        }
        
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            if mainViewModel.userState == .setRidePoint {
                Task {
                    await mainViewModel.setRideLocation(coordinates: context.region.center)
                    print("DEBUG: 逆ジオエンコーティング実行\nUserStateは → \(mainViewModel.userState)")  // デバッグ用
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
            
            // Button
            if mainViewModel.userState == .confirming {
                
                HStack(spacing: 16) {
                    Button {
                        mainViewModel.reset()
                    } label: {
                        Text("キャンセル")
                            .modifier(BasicButton(isPrimary: false))
                    }
                    
                    Button {
                        
                    } label: {
                        Text("タクシーを呼ぶ")
                            .modifier(BasicButton())
                    }
                }
                
            } else {
                
                Button {
                    // 1. ユーザーの状態を「目的地検索中」に切り替え
                    mainViewModel.userState = .searchLocation
                    print("UserState変更: \(mainViewModel.userState)")  // デバッグ用
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
                    if mainViewModel.userState != .confirming {
                        mainViewModel.userState = .setRidePoint
                    }
                    print("UserState変更: \(mainViewModel.userState)")  // デバッグ用
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
