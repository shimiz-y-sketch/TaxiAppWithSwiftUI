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
    
    @State private var showSearchView = false
    // 書記画面表示用のバインディング変数（固定値）
//    @State private var cameraPosition: MapCameraPosition = .region(
//        MKCoordinateRegion(
//            center: .init(latitude: 35.452183, longitude: 139.632419),
//            latitudinalMeters: 10000,
//            longitudinalMeters: 10000)
//        )
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
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
        Map(position: $cameraPosition) {
            UserAnnotation()
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
                mainViewModel.userState = .searchLocation
                print("UserState変更: \(mainViewModel.userState)")  // デバッグ用
                showSearchView.toggle()
            } label: {
                Text("目的地を指定する")
                    .modifier(BasicButton())
            }
            .sheet(isPresented: $showSearchView) {
                mainViewModel.userState = .setRidePoint
                print("UserState変更: \(mainViewModel.userState)")  // デバッグ用
            } content: {
                SearchView(center: mainViewModel.ridePointCoordinates)
                    .environmentObject(mainViewModel)
            }


        }
        .padding(.horizontal)
        .frame(height: 240)
    }
}
