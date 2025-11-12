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
                "geoPoint": GeoPoint(latitude: 34.7, longitude: 135.51)
            ])
            print("DEBUG: ドキュメントを初期化")
        } catch {
            print("DEBUG: ドキュメントの初期化に失敗： \(error.localizedDescription)")
        }
    }
    
    /// デバッグ用：指定されたタクシーを指定された経路（`points`配列）に沿って移動させる
    ///
    /// - Parameters:
    ///   - id: 移動させるタクシーのドキュメントID
    ///   - state: 現在のタクシーの状態。この状態に応じて移動経路（toRidePoint または toDestination）を選択する
    ///   - delay: 各ポイント間の移動をシミュレーションするための待機時間（秒、デフォルトは1.0秒）
    static func moveTaxi(id: String, state: TaxiState, delay: Double = 1.0) async {
        // 選択された状態に基づいて移動経路を保持する配列
        var points: [GeoPoint] = []
        
        // タクシーの現在の状態に基づいて、使用する経路データを決定
        switch state {
            // 移動を伴わない状態の場合、処理を終了する
        case .empty, .arrivedAtRidePoint, .arrivedAtDestination:
            return
            // 乗車地へ向かっている状態の場合、乗車地への経路を使用
        case .goingToRidePoint:
            points = toRidePoint
            // 目的地へ向かっている状態の場合、目的地への経路を使用
        case .goingToDestination:
            points = toDestination
        }
        
        // 経路上の各ポイントについて順次処理を実行
        for point in points {
            do {
                // 指定された時間だけ処理を一時停止し、移動をシミュレーション
                try await Task.sleep(for: .seconds(delay))
                
                // Firestoreの該当ドキュメントの "geoPoint" フィールドを現在のポイントに更新
                try await Firestore.firestore().collection("taxis").document(id).updateData([
                    "geoPoint": point
                ])
            } catch {
                print("FirestoreでgeoPointの更新に失敗： \(error.localizedDescription)")
            }
            
        }
    }
    
    /// 乗車地へ向かう経路（6点）
    // スタート地点 (34.700000, 135.510000) から 乗車地 (34.703301, 135.504417) までの6点
    static let toRidePoint: [GeoPoint] = [
        GeoPoint(latitude: 34.700550, longitude: 135.509069), // 1/6
        GeoPoint(latitude: 34.701100, longitude: 135.508138), // 2/6
        GeoPoint(latitude: 34.701651, longitude: 135.507206), // 3/6
        GeoPoint(latitude: 34.702201, longitude: 135.506275), // 4/6
        GeoPoint(latitude: 34.702751, longitude: 135.505343), // 5/6
        GeoPoint(latitude: 34.703301, longitude: 135.504417)  // 6/6 (乗車地)
    ]
    
    /// 目的地へ向かう経路（10点）
    // 乗車地 (34.703301, 135.504417) から 目的地 (34.704900, 135.508000) までの10点
    static let toDestination: [GeoPoint] = [
        GeoPoint(latitude: 34.703461, longitude: 135.504775), // 1/10
        GeoPoint(latitude: 34.703621, longitude: 135.505134), // 2/10
        GeoPoint(latitude: 34.703781, longitude: 135.505492), // 3/10
        GeoPoint(latitude: 34.703941, longitude: 135.505851), // 4/10
        GeoPoint(latitude: 34.704101, longitude: 135.506209), // 5/10
        GeoPoint(latitude: 34.704261, longitude: 135.506568), // 6/10
        GeoPoint(latitude: 34.704421, longitude: 135.506927), // 7/10
        GeoPoint(latitude: 34.704581, longitude: 135.507285), // 8/10
        GeoPoint(latitude: 34.704740, longitude: 135.507644), // 9/10
        GeoPoint(latitude: 34.704900, longitude: 135.508000)  // 10/10 (目的地)
    ]
}
