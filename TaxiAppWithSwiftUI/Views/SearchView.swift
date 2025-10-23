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
            inputField
            
            Divider()
            
            // Results
            searchResults
        }
    }
}

#Preview {
    SearchView()
}

extension SearchView {
    
    private var inputField: some View {
        Capsule()
            .fill(Color.mint)
            .frame(height: 70)
            .padding()
    }
    
    private var searchResults: some View {
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
