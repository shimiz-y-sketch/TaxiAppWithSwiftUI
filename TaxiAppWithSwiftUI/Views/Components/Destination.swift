//
//  Destination.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/23.
//

import SwiftUI

struct Destination: View {
    var body: some View {
        
        HStack(spacing: 12) {
            Image(systemName: "mappin.and.ellipse")
                .imageScale(.large)
            
            VStack(alignment: .leading) {
                Text("目的地")
                    .font(.subheadline)
                Text("指定してください")
                    .font(.headline)
            }
            Spacer()
        }
        .foregroundStyle(.secondary)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
}

#Preview {
    Destination()
}
