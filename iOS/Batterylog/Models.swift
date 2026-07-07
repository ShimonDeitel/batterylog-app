import Foundation

struct BatterylogEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var date: Date = Date()
    var voltage: String = ""
    var brand: String = ""
    var note: String = ""
}
