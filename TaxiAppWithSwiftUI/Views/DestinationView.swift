//
//  DestinationView.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/22.
//

import SwiftUI

struct DestinationView: View {
    
    @Environment(\.dismiss) var dismiss
    
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
    SearchView()
//    NavigationStack {
//        DestinationView()
//    }
}

extension DestinationView {
    
    private var map: some View {
        Color.mint
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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .background(.black)
                    .clipShape(Capsule())
            }

            
        }
        .padding(.horizontal)
        .padding(.top, 14)
    }

}
