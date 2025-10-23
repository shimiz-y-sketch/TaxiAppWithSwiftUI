//
//  MainView.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/22.
//

import SwiftUI

struct MainView: View {
    
    @State private var showSearchView = false
    
    var body: some View {
        VStack {
            // Map Area
            map
            
            // Information Area
            information
        }
        .sheet(isPresented: $showSearchView) {
            SearchView()
        }
    }
}

#Preview {
    MainView()
}

extension MainView {
    
    private var map: some View {
        Color.gray
    }
    
    private var information: some View {
        VStack {
            // Starting Point
            HStack(spacing: 12) {
                Image(systemName: "figure.wave")
                    .imageScale(.large)
                VStack(alignment: .leading) {
                    HStack {
                        Text("乗車地")
                            .font(.subheadline)
                        Text("地図を動かして地点を調整")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    Text("横浜市西区みなとみらい1-1")
                        .font(.headline)
                    
                }
                Spacer()
            }
            .padding(.vertical)
            
            // Destination
            Destination()
            
            Spacer()
            
            // Button
            Button {
                showSearchView.toggle()
            } label: {
                Text("目的地を指定する")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .background(.black)
                    .clipShape(Capsule())
            }

        }
        .padding(.horizontal)
        .frame(height: 240)
    }
}
