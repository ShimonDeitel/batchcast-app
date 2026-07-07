import Foundation

@MainActor
final class BatchCastStore: ObservableObject {
    @Published private(set) var casts: [Cast] = []
    @Published private(set) var proEntries: [BCProEntry] = []

    static let freeLimit = 30

    private let fileURL: URL
    private let proFileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("batchcast_casts.json")
        self.proFileURL = dir.appendingPathComponent("batchcast_pro.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: proFileURL)
        }
        load()
        if casts.isEmpty {
            seedDefaults()
        }
        if proEntries.isEmpty {
            seedProDefaults()
        }
    }

    private func seedDefaults() {
        casts = [
            Cast(pieceName: "Signet Ring", metalType: "Sterling Silver", weightGrams: "8.5", burnoutSchedule: "1350F/2hr"),
            Cast(pieceName: "Pendant", metalType: "14k Gold", weightGrams: "3.2", burnoutSchedule: "1400F/3hr")
        ]
        save()
    }

    private func seedProDefaults() {
        proEntries = [
            BCProEntry(metalType: "14k Gold", weightGrams: "3.2", pricePerGram: "65", estimatedCost: "208"),
            BCProEntry(metalType: "Sterling Silver", weightGrams: "8.5", pricePerGram: "0.9", estimatedCost: "7.65")
        ]
        saveProEntries()
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || casts.count < Self.freeLimit
    }

    @discardableResult
    func addCast(pieceName: String, metalType: String, weightGrams: String, burnoutSchedule: String, isPro: Bool) -> Bool {
        let trimmed = pieceName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAdd(isPro: isPro) else { return false }
        let item = Cast(pieceName: pieceName, metalType: metalType, weightGrams: weightGrams, burnoutSchedule: burnoutSchedule)
        casts.append(item)
        save()
        return true
    }

    func updateCast(_ id: UUID, pieceName: String, metalType: String, weightGrams: String, burnoutSchedule: String) {
        guard let idx = casts.firstIndex(where: { $0.id == id }) else { return }
        casts[idx].pieceName = pieceName
        casts[idx].metalType = metalType
        casts[idx].weightGrams = weightGrams
        casts[idx].burnoutSchedule = burnoutSchedule
        save()
    }

    func deleteCast(_ id: UUID) {
        casts.removeAll { $0.id == id }
        save()
    }

    func deleteAllData() {
        casts = []
        proEntries = []
        seedDefaults()
        seedProDefaults()
    }

    // MARK: - Pro entries

    @discardableResult
    func addProEntry(metalType: String, weightGrams: String, pricePerGram: String, estimatedCost: String) -> Bool {
        let entry = BCProEntry(metalType: metalType, weightGrams: weightGrams, pricePerGram: pricePerGram, estimatedCost: estimatedCost)
        proEntries.append(entry)
        saveProEntries()
        return true
    }

    func deleteProEntry(_ id: UUID) {
        proEntries.removeAll { $0.id == id }
        saveProEntries()
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var items: [Cast]
    }
    private struct ProSnapshot: Codable {
        var items: [BCProEntry]
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            casts = decoded.items
        }
        if let data = try? Data(contentsOf: proFileURL), let decoded = try? JSONDecoder().decode(ProSnapshot.self, from: data) {
            proEntries = decoded.items
        }
    }

    private func save() {
        let snapshot = Snapshot(items: casts)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func saveProEntries() {
        let snapshot = ProSnapshot(items: proEntries)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: proFileURL, options: .atomic)
    }
}
