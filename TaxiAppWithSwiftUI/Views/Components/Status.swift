//
//  Status.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/11/10.
//

import SwiftUI

/// ユーザーの現在の配車状態（手配中、到着済みなど）を示すView
struct Status: View {
    
    // 外部から渡されるタクシーの状態（.goingToRidePoint, .arrivedAtRidePoint, .goingToDestinationなど）
    let state: TaxiState
    
    var body: some View {
        VStack {
            // Status bar (進行状況を示すアイコンとバーのレイアウト)
            HStack {
                // ステータス1: 手配（配車開始）
                imageAndText(
                    imageName: state == .empty ? "figure.wave.circle" : "checkmark.circle.fill",
                    text: "手配"
                )
                
                Spacer() // ステータス要素間のスペース
                
                // ステータスバー1: 手配 -> 乗車
                if state == .empty {
                    bar(progress: .notStarted) // 配車前: 未開始の状態（バーは薄いまま）
                } else if state == .goingToRidePoint {
                    bar(progress: .middle) // 乗車地へ移動中: バーの半分をアクティブ化
                } else {
                    bar(progress: .arrived) // 乗車地到着済み: バー全体をアクティブ化
                }
                
                Spacer()
                
                // ステータス2: 乗車（乗車地到着）
                imageAndText(
                    imageName: state == .empty || state == .goingToRidePoint ? "car.circle" : "checkmark.circle.fill",
                    text: "乗車"
                )
                
                Spacer()
                
                // ステータスバー2: 乗車 -> 到着
                if state == .goingToDestination {
                    bar(progress: .middle) // 目的地へ移動中: バーの半分をアクティブ化
                } else if state == .arrivedAtDestination {
                    bar(progress: .arrived) // 目的地到着済み: バー全体をアクティブ化
                } else {
                    bar(progress: .notStarted) // それ以外: 未開始の状態
                }
                
                Spacer()
                
                // ステータス3: 到着（目的地到着）
                imageAndText(
                    imageName: state == .arrivedAtDestination ? "checkmark.circle.fill" : "checkmark.circle",
                    text: "到着"
                )
            }
        }
        .foregroundStyle(.main) // すべての要素にアプリのメインカラーを適用
        
        // Message text (現在の状態に対応するメッセージを表示する部分)
        Text(state.message) // このテキストは状態に応じて動的に変更する必要がある
            .font(.headline)
            .padding(.top, 10) // ステータスバーとメッセージの間隔
        
        
    }
}

#Preview {
    Status(state: .empty)
}

enum Progress {
    case notStarted, middle, arrived
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
    
    /// ステータス要素間の進行バーを表現する関数
    /// progressの値に応じて、バーのアクティブ状態（opacity）を制御する
    private func bar(progress: Progress) -> some View {
        HStack(spacing: 0) {
            // バーの前半部分: notStarted以外ならアクティブ
            Rectangle()
                .frame(width: 50, height: 4)
                .opacity(progress == .notStarted ? 0.2 : 1.0) // .notStartedなら薄く、他は濃く
            // バーの後半部分: arrivedのみアクティブ
            Rectangle()
                .frame(width: 50, height: 4)
                .opacity(progress == .arrived ? 1.0 : 0.2) // .arrivedなら濃く、他は薄く
        }
    }
    
}
