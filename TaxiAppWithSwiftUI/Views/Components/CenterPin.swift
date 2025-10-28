//
//  CenterPin.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/27.
//

import SwiftUI

struct CenterPin: View {
    var body: some View {
        ZStack(alignment: .top) {
            
            Image(systemName: "mappin")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            
            Image(systemName: "circle.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .offset(y: -4)
            
            Image(systemName: "circle.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 8)
                .offset(y: 4)
                .foregroundStyle(.white)
            
        }
        .offset(y: -20)
        .foregroundStyle(.main)
    }
}

#Preview {
    CenterPin()
}
