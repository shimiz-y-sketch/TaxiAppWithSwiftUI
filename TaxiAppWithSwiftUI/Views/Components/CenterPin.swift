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
                .frame(height: Constants.pinHeight)
            
            Image(systemName: "circle.fill")
                .resizable()
                .scaledToFit()
                .frame(height: Constants.pinHeight * 0.6)
                .offset(y: Constants.pinHeight * -0.1)
            
            Image(systemName: "circle.fill")
                .resizable()
                .scaledToFit()
                .frame(height: Constants.pinHeight * 0.2)
                .offset(y: Constants.pinHeight * 0.1)
                .foregroundStyle(.white)
            
        }
        .offset(y: -Constants.pinHeight / 2)
        .foregroundStyle(.main)
    }
}

#Preview {
    CenterPin()
}
