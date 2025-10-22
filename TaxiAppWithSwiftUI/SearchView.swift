//
//  SearchView.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/22.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        VStack(spacing: 0) {
            
            Divider()
            
            // Input Field
            Capsule()
                .fill(Color.red)
                .frame(height: 70)
                .padding()
            
            Divider()
            
            // Results
            ScrollView {
                VStack(spacing: 16) {
                    Text("検索結果")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(0..<10) { _ in
                        RoundedRectangle(cornerRadius: 18)
                            .frame(height: 70)
                    }

                }
                .padding()
            }
            .background(Color(.secondarySystemBackground))
        }
    }
}

#Preview {
    SearchView()
}
