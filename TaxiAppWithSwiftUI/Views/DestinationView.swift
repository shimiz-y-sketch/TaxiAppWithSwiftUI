//
//  DestinationView.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/22.
//

import SwiftUI

struct DestinationView: View {
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
    DestinationView()
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
            Capsule()
                .frame(height: 60)
            
        }
        .padding(.horizontal)
        .padding(.top, 14)
    }

}
