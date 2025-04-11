
//  ContentView.swift
//  Calculator
//
//  Created by Koki Komatsu on 2025/04/12.
//

import SwiftUI

import SwiftData // SwiftDataをインポート

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext // ModelContextを環境から取得
    @StateObject private var calculator = CalculatorModel()
    @State private var showingHistory = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                VStack(spacing: 12) {
                    Spacer()
                    // Display
                    HStack {
                        Spacer()
                        Text(calculator.display)
                            .font(.system(size: geometry.size.height * 0.1, weight: .light))
                            .foregroundColor(.white)
                            .padding(.trailing, 24)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .frame(height: geometry.size.height * 0.15)
                    
                    // Buttons
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            CalculatorButton(label: calculator.clearButtonLabel, color: .gray, action: { calculator.clear() }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "HIS", color: .gray, action: { showingHistory.toggle() }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "%", color: .gray, action: { calculator.percent() }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "÷", color: .orange, action: { calculator.setOperation(.division) }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                        }
                        HStack(spacing: 12) {
                            CalculatorButton(label: "7", color: Color(white: 0.2), action: { calculator.appendDigit("7") }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "8", color: Color(white: 0.2), action: { calculator.appendDigit("8") }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "9", color: Color(white: 0.2), action: { calculator.appendDigit("9") }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "×", color: .orange, action: { calculator.setOperation(.multiplication) }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                        }
                        HStack(spacing: 12) {
                            CalculatorButton(label: "4", color: Color(white: 0.2), action: { calculator.appendDigit("4") }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "5", color: Color(white: 0.2), action: { calculator.appendDigit("5") }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "6", color: Color(white: 0.2), action: { calculator.appendDigit("6") }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "-", color: .orange, action: { calculator.setOperation(.subtraction) }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                        }
                        HStack(spacing: 12) {
                            CalculatorButton(label: "1", color: Color(white: 0.2), action: { calculator.appendDigit("1") }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "2", color: Color(white: 0.2), action: { calculator.appendDigit("2") }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "3", color: Color(white: 0.2), action: { calculator.appendDigit("3") }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            CalculatorButton(label: "+", color: .orange, action: { calculator.setOperation(.addition) }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                        }
                        HStack(spacing: 12) {
                            CalculatorButton(label: "0", color: Color(white: 0.2), action: { calculator.appendDigit("0") }, width: geometry.size.width * 0.45, height: geometry.size.height * 0.1, isWide: true)
                            CalculatorButton(label: ".", color: Color(white: 0.2), action: { calculator.appendDecimal() }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                            // `=` ボタンのアクションで modelContext を渡す
                            CalculatorButton(label: "=", color: .orange, action: { calculator.calculate(context: modelContext) }, width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            // .sheet モディファイアを使用して履歴ビューを表示
            .sheet(isPresented: $showingHistory) {
                HistoryView(calculator: calculator, onDismiss: { showingHistory = false })
            }
        }
        .ignoresSafeArea() // ZStack全体ではなく、背景色に適用する方が一般的ですが、元の挙動を維持
    }
}

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext // ModelContextを取得
    @ObservedObject var calculator: CalculatorModel // CalculatorModelは再利用のために必要
    let onDismiss: () -> Void

    // SwiftDataから履歴を取得 (タイムスタンプで降順ソート)
    @Query(
        sort: [SortDescriptor(\CalculationHistoryEntry.timestamp, order: .reverse)],
        animation: .default
    ) private var historyEntries: [CalculationHistoryEntry]
    
    // デバッグ用: 履歴エントリが変更された時にログを出力
    private func logHistoryChanges() {
        print("Current history entries count: \(historyEntries.count)")
        for entry in historyEntries {
            print("Entry: \(entry.expression), \(entry.timestamp)")
        }
    }

    var body: some View {
        logHistoryChanges() // 履歴状態をログ出力
        return NavigationView { // ナビゲーションビューを追加してタイトルバーを表示
            List {
                // 履歴がない場合の表示
                if historyEntries.isEmpty {
                    Text("履歴はありません")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(historyEntries) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.expression)
                                .font(.headline) // 式を少し大きく
                            Text(entry.timestamp.formatted(.dateTime.year().month().day().hour().minute())) // yyyy/MM/dd HH:mm形式
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4) // 縦のパディングを少し追加
                        .contentShape(Rectangle()) // タップ領域を広げる
                        .onTapGesture { // タップで再利用
                            reuseHistoryEntry(entry)
                            onDismiss()
                        }
                        .swipeActions(edge: .trailing) { // 右スワイプで削除
                            Button(role: .destructive) {
                                deleteHistoryEntry(entry)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped) // リストスタイルを変更
            .navigationTitle("計算履歴") // ナビゲーションバーのタイトル
            .navigationBarTitleDisplayMode(.inline) // タイトルをインライン表示
            .toolbar {
                // 左上に全削除ボタン
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("全削除", role: .destructive) {
                        clearHistory()
                    }
                    .disabled(historyEntries.isEmpty) // 履歴が空なら無効化
                }
                // 右上に閉じるボタン
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる", action: onDismiss)
                }
            }
        }
    }

    // 履歴の再利用
    private func reuseHistoryEntry(_ entry: CalculationHistoryEntry) {
        // 式から結果部分 ("= " の後) を抽出
        if let resultString = entry.expression.split(separator: "=").last?.trimmingCharacters(in: .whitespaces) {
             // 結果を display に反映 (CalculatorModel のメソッドは使わない)
            calculator.display = String(resultString)
            // 必要であれば currentNumber も更新する (今回は display のみ更新)
            // if let number = Double(resultString) {
            //     calculator.currentNumber = number // CalculatorModelのプロパティ直接変更は避けるべきだが、今回は簡易的に
            // }
        }
    }

    // 履歴の削除 (単一)
    private func deleteHistoryEntry(_ entry: CalculationHistoryEntry) {
        modelContext.delete(entry)
    }

    // 履歴の全削除
    private func clearHistory() {
        do {
            try modelContext.delete(model: CalculationHistoryEntry.self)
            onDismiss() // 全削除後に履歴画面を閉じる
        } catch {
            print("Failed to delete history: \(error)")
        }
    }
}


struct CalculatorButton: View {
    let label: String
    let color: Color
    let action: () -> Void
    let width: CGFloat
    let height: CGFloat
    var isWide: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 100)
                    .foregroundColor(color)
                    .opacity(0.9)
                Text(label)
                    .font(.system(size: height * 0.4, weight: .medium))
                    .foregroundColor(color == .orange ? .white : .white)
            }
            .frame(width: width, height: height)
        }
        .contentShape(Rectangle())
    }
}

import SwiftData // SwiftDataをインポート

class CalculatorModel: ObservableObject {
    @Published var display: String = "0"
    // @Published var history: [String] = [] // SwiftDataで管理するため削除
    private var currentNumber: Double = 0
    private var previousNumber: Double = 0
    private var currentOperation: Operation?
    private var shouldResetInput: Bool = false
    private var lastExpression: String = ""
    private var clearType: ClearType = .allClear // AC/C状態管理
    var clearButtonLabel: String {
        clearType == .allClear ? "AC" : "C"
    }
    
    enum ClearType {
        case allClear
        case clear
    }
    
    enum Operation {
        case addition, subtraction, multiplication, division
    }
    
    func appendDigit(_ digit: String) {
        if display == "0" || shouldResetInput {
            display = digit
            shouldResetInput = false
        } else {
            display += digit
        }
        currentNumber = Double(display) ?? 0
        clearType = .clear // 数字入力時にCボタンに切り替え
    }
    
    func appendDecimal() {
        if !display.contains(".") {
            display += "."
        }
        shouldResetInput = false
    }
    
    func setOperation(_ operation: Operation) {
        currentOperation = operation
        previousNumber = currentNumber
        shouldResetInput = true
    }
    
    // ModelContextを引数で受け取るように変更
    func calculate(context: ModelContext) {
        guard let operation = currentOperation else { return }
        
        // 計算前に式を構築（デバッグログ追加）
        print("Building expression - previous: \(previousNumber), current: \(currentNumber)")
        var expression: String
        switch operation {
        case .addition:
            expression = "\(formatNumber(previousNumber)) + \(formatNumber(currentNumber))"
            print("Addition expression: \(expression)")
            currentNumber = previousNumber + currentNumber
        case .subtraction:
            expression = "\(formatNumber(previousNumber)) - \(formatNumber(currentNumber))"
            print("Subtraction expression: \(expression)")
            currentNumber = previousNumber - currentNumber
        case .multiplication:
            expression = "\(formatNumber(previousNumber)) × \(formatNumber(currentNumber))"
            print("Multiplication expression: \(expression)")
            currentNumber = previousNumber * currentNumber
        case .division:
            if currentNumber != 0 {
                expression = "\(formatNumber(previousNumber)) ÷ \(formatNumber(currentNumber))"
                print("Division expression: \(expression)")
                currentNumber = previousNumber / currentNumber
            } else {
                display = "エラー"
                return
            }
        }
        
        // 結果を含めた完全な式を構築
        let calculationExpression = "\(expression) = \(formatNumber(currentNumber))"
        
        display = formatNumber(currentNumber)
        
        // SwiftDataに履歴を保存
        print("Attempting to save calculation history...")
        let newEntry = CalculationHistoryEntry(expression: calculationExpression, timestamp: Date())
        print("New entry created: \(newEntry.expression)")
        
        context.insert(newEntry)
        print("Entry inserted into context")
        
        do {
            try context.save() // 明示的に保存して確実に反映
            print("Successfully saved history entry")
            
            // 保存後にコンテキストの状態を確認
            let fetchRequest = FetchDescriptor<CalculationHistoryEntry>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let entries = try? context.fetch(fetchRequest)
            print("Current entries in context: \(entries?.count ?? 0)")
            
        } catch {
            print("Failed to save history entry: \(error.localizedDescription)")
            print("Detailed error: \(error)")
            
            // コンテキストの状態を確認
            let fetchRequest = FetchDescriptor<CalculationHistoryEntry>()
            let entries = try? context.fetch(fetchRequest)
            print("Current entries after failed save: \(entries?.count ?? 0)")
        }
        
        currentOperation = nil
        previousNumber = 0
        shouldResetInput = false // 計算後は新しい入力を期待するためfalseのまま
    }
    
    func clear() {
        if clearType == .allClear {
            // AC: 全リセット
            display = "0"
            currentNumber = 0
            previousNumber = 0
            currentOperation = nil
            shouldResetInput = false
            clearType = .allClear
        } else {
            // C: 現在の入力のみクリア
            display = "0"
            currentNumber = 0
            shouldResetInput = false
            clearType = .allClear
        }
    }
    
    func toggleHistory() {
        // This function is now handled in the View
    }
    
    // ModelContextを引数で受け取るように変更
    func clearHistory(context: ModelContext) {
        // SwiftDataから全履歴を削除
        do {
            try context.delete(model: CalculationHistoryEntry.self)
        } catch {
            print("Failed to delete history: \(error)")
        }
    }
    
    // CalculationHistoryEntryを引数で受け取るように変更
    func deleteHistoryEntry(_ entry: CalculationHistoryEntry, context: ModelContext) {
        // SwiftDataから特定の履歴を削除
        context.delete(entry)
    }
    
    // 履歴の再利用ロジックはView側で処理するため削除
    // func reuseHistoryEntry(_ entry: String) { ... }
    
    func percent() {
        currentNumber = currentNumber / 100
        display = formatNumber(currentNumber)
    }
    
    private func formatNumber(_ number: Double) -> String {
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", number)
        } else {
            return String(number)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    } // <--- 閉じ括弧を追加
} // <--- ContentView_Previews の閉じ括弧を追加
