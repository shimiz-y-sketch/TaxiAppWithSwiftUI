//
//  DestinationView.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/22.
//

import SwiftUI
import MapKit

struct DestinationView: View {
    
    let placemark: MKPlacemark
    @Environment(\.dismiss) var dismiss
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
            VStack {
                // Map Area
                map
                
                // Information Area
                information
            }
            .navigationTitle("地点を確認・調整")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                    }

                }
            }
        }
}

#Preview {
        DestinationView(placemark: .init(coordinate: .init(latitude: 35.452183, longitude: 139.632419)))
        // 参考：省略なしの記法は以下
        //DestinationView.init(placemark: MKPlacemark.init(coordinate: CLLocationCoordinate2D.init(latitude: 35.452183, longitude: 139.632419)))
}

extension DestinationView {
    
    private var map: some View {
        Map(position: $cameraPosition) {
            
        }
        .onAppear {
            cameraPosition = .camera(MapCamera(centerCoordinate: placemark.coordinate, distance: 1000))
        }
        .onMapCameraChange(frequency: .onEnd) { context in

        }
    }
    
    private var information: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Caption
            VStack(alignment: .leading) {
                Text("この場所でよろしいですか？")
                    .font(.title3.bold())
                Text("地図を動かして地点を調整")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            // Destination
            Destination()
            
            // Button
            Button {
                print("ボタンがタップされました")
            } label: {
                Text("ここに行く")
                    .modifier(BasicButton())
            }

            
        }
        .padding(.horizontal)
        .padding(.top, 14)
    }

}
