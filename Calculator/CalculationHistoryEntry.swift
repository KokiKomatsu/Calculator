import Foundation
import SwiftData

@Model
final class CalculationHistoryEntry {
    var expression: String
    var timestamp: Date

    init(expression: String = "", timestamp: Date = Date()) {
        self.expression = expression
        self.timestamp = timestamp
    }
}
