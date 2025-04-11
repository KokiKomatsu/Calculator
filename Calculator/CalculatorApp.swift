//  CalculatorApp.swift
//  Calculator
//
//  Created by Koki Komatsu on 2025/04/12.
//

import SwiftUI
import SwiftData // SwiftDataをインポート

@main
struct CalculatorApp: App {
    // SwiftDataのモデルコンテナを作成
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CalculationHistoryEntry.self, // 作成したモデルクラスを指定
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // modelContainerを環境に設定
        .modelContainer(sharedModelContainer)
    }
}
