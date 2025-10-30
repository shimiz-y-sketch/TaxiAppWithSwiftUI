//
//  Destination.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/23.
//

import SwiftUI

struct Destination: View {
    
    var address: String?
    
    var body: some View {
        
        HStack(spacing: 12) {
            Image(systemName: "mappin.and.ellipse")
                .imageScale(.large)
            
            VStack(alignment: .leading) {
                Text("目的地")
                    .font(.subheadline)
                Text(address ?? "指定してください")
                    .font(.headline)
            }
            Spacer()
        }
        .foregroundStyle(address == nil ? .secondary : .primary)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
}

#Preview {
    Destination()
}
