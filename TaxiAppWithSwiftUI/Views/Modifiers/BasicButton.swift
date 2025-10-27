//
//  BasicButton.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/24.
//


import SwiftUI

struct BasicButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .background(.main)
            .clipShape(Capsule())
    }
}
