import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var entries: [BatterylogEntry] = []
    @Published var categoryTogglesEnabled: Bool = true

    /// Free tier item cap. Seed data count is always well below this.
    static let freeLimit = 15

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("batterylog_entries.json")
        load()
    }

    var isAtFreeLimit: Bool {
        entries.count >= Store.freeLimit
    }

    func add(_ entry: BatterylogEntry) -> Bool {
        guard !isAtFreeLimit else { return false }
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: BatterylogEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: BatterylogEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([BatterylogEntry].self, from: data) {
            entries = decoded
        } else {
            entries = Self.seedData()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    static func seedData() -> [BatterylogEntry] {
        (1...2).map { i in
            BatterylogEntry(title: "Sample Battery Check \(i)", date: Date(), voltage: "Example", brand: "—", note: "")
        }
    }
}
