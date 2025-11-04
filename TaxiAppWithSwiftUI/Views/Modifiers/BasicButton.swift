//
//  BasicButton.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/10/24.
//


import SwiftUI

struct BasicButton: ViewModifier {
    
    var isPrimary: Bool = true
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .fontWeight(.bold)
            .foregroundStyle(isPrimary ? .white : .primary)
            .background(isPrimary ? .main : Color(.systemFill))
            .clipShape(Capsule())
    }
}
