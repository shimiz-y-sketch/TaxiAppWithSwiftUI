//
//  Debug.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/11/12.
//

import Foundation
import FirebaseFirestore

struct Debug {
    /// デバッグ用：Firestore上の特定のタクシー（ID: Shpqkh5tV9pW8wQ3aavd）のデータと位置を初期状態（空車）に戻す
        static func setTaxi() async {
            do {
                // Firestoreの "taxis" コレクション内の特定のドキュメントを更新
                try await Firestore.firestore().collection("taxis").document("Shpqkh5tV9pW8wQ3aavd").updateData([
                    // 状態を「空車 (.empty)」にリセット
                    "state": TaxiState.empty.rawValue,
                    // 初期座標にリセット
                    "geoPoint": GeoPoint(latitude: 34.703381, longitude: 135.504917)
                ])
                print("DEBUG: ドキュメントを初期化")
            } catch {
                print("DEBUG: ドキュメントの初期化に失敗： \(error.localizedDescription)")
            }
        }
}
