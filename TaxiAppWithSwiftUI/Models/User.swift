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
    let number: String
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
