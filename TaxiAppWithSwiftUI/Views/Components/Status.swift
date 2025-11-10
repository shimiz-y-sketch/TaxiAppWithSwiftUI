//
//  Status.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/11/10.
//

import SwiftUI

/// ユーザーの現在の配車状態（手配中、到着済みなど）を示すView
struct Status: View {
    var body: some View {
        VStack {
            // Status bar
            HStack {
                imageAndText(
                    imageName: "figure.wave.circle",
                    text: "手配"
                )
                
                Spacer()
                
                bar
                
                Spacer()
                
                imageAndText(
                    imageName: "car.circle",
                    text: "乗車"
                )
                
                Spacer()
                
                bar
                
                Spacer()
                
                imageAndText(
                    imageName: "checkmark.circle",
                    text: "到着"
                )
            }
        }
        .foregroundStyle(.main)
        // Message test
        Text("タクシーを手配しています")
            .font(.headline)
        
        
    }
}

#Preview {
    Status()
}

// MARK: - Reusable Components
extension Status {
    
    /// アイコンとテキストを縦に並べたステータス要素を生成する関数
    private func imageAndText(imageName: String, text: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: imageName)
                .imageScale(.large)
            Text(text)
                .font(.caption)
                .fontWeight(.bold)
            
        }
    }
    
    /// ステータス要素間の進行バーを表現するプロパティ
    private var bar: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 50, height: 4)
                .opacity(0.2)
            Rectangle()
                .frame(width: 50, height: 4)
                .opacity(0.2)
        }
    }
    
}
