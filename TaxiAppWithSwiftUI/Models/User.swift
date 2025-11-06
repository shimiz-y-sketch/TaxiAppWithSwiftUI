//
//  User.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/11/06.
//

import Foundation

/// アプリケーション利用ユーザーのデータモデル
struct User {
    /// ユーザーを一意に識別するためのID
    let id: String
    /// ユーザーの識別番号
    let name: String
    /// ユーザーのメールアドレス
    let email: String
    /// ユーザーが現在アプリ上でどの操作段階にいるかを示す状態
    var state: UserState
}

/// ユーザーが現在アプリで実行している操作の状態
enum UserState {
    /// 乗車地を設定している状態
    case setRidePoint
    /// 目的地を検索している状態
    case searchLocation
    /// 目的地を設定し、確認画面を見ている状態
    case setDestination
    /// ルートを確認し、配車を確定しようとしている状態
    case confirming
}

// 開発用モックデータ
extension User {
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        [
            User(
                id: "1",
                name: "ブルー",
                email: "test1@example.com",
                state: .setRidePoint
            ),
            User(
                id: "2",
                name: "パープル",
                email: "test2@example.com",
                state: .setRidePoint
            ),
            User(
                id: "3",
                name: "ピンク",
                email: "test3@example.com",
                state: .setRidePoint
            ),
            User(
                id: "4",
                name: "グリーン",
                email: "test4@example.com",
                state: .setRidePoint
            ),
            User(
                id: "5",
                name: "イエロー",
                email: "test5@example.com",
                state: .setRidePoint
            )
        ]
    }
}
