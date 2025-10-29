//
//  MainView.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/22.
//

import SwiftUI
import MapKit

struct MainView: View {
    
    @ObservedObject var mainViewModel = MainViewModel()
    
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
            UserAnnotation()
            
            if let polyline = mainViewModel.route?.polyline {
                MapPolyline(polyline)
                    .stroke(.blue, lineWidth: 7)
            }
        }
        .overlay {
            CenterPin()
        }
        
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            if mainViewModel.userState == .setRidePoint {
                let center = context.region.center
                Task {
                    await mainViewModel.setRideLocation(latitude: center.latitude, longitude: center.longitude)
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
                    
                    Text(mainViewModel.ridePointAddress)
                        .font(.headline)
                    
                }
                Spacer()
            }
            .padding(.vertical)
            
            // Destination
            Destination(address: "設定してください")
                .overlay(alignment: .topLeading)  {
                    VStack {
                        Image(systemName: "arrowtriangle.down.fill")
                        Image(systemName: "arrowtriangle.down.fill").opacity(0.66)
                        Image(systemName: "arrowtriangle.down.fill").opacity(0.33)
                    }
                    .font(.caption2)
                    .foregroundStyle(.main)
                    .offset(x: 8, y: -16)
                    
                }
            
            Spacer()
            
            // Button
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
                
                // 3. ユーザーの状態を「乗車地設定中」に戻す
                mainViewModel.userState = .setRidePoint
                print("UserState変更: \(mainViewModel.userState)")  // デバッグ用
            } content: {
                // 4. モーダルとして表示するView（検索画面）の定義
                
                // 現在の乗車地座標を検索の中心として渡す
                SearchView(center: mainViewModel.ridePointCoordinates)
                    // SearchViewとその子孫ViewでMainViewModelを利用できるように環境に登録
                    .environmentObject(mainViewModel)
            }


        }
        .padding(.horizontal)
        .frame(height: 240)
    }
}
