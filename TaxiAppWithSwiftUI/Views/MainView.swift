//
//  MainView.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/22.
//

import SwiftUI
import MapKit

struct MainView: View {
    
    let mainViewModel = MainViewModel()
    
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
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
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
                    
                    Text(mainViewModel.strPointName)
                        .font(.headline)
                    
                }
                Spacer()
            }
            .padding(.vertical)
            
            // Destination
            Destination()
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
                showSearchView.toggle()
            } label: {
                Text("目的地を指定する")
                    .modifier(BasicButton())
            }
            .sheet(isPresented: $showSearchView) {
                SearchView()
            }

        }
        .padding(.horizontal)
        .frame(height: 240)
    }
}
