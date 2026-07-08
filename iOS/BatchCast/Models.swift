import Foundation

struct Cast: Identifiable, Codable, Equatable {
    let id: UUID
    var pieceName: String
    var metalType: String
    var weightGrams: String
    var burnoutSchedule: String
    var createdDate: Date

    init(id: UUID = UUID(), pieceName: String = "Signet Ring", metalType: String = "Sterling Silver", weightGrams: String = "8.5", burnoutSchedule: String = "1350F/2hr", createdDate: Date = Date()) {
        self.id = id
        self.pieceName = pieceName
        self.metalType = metalType
        self.weightGrams = weightGrams
        self.burnoutSchedule = burnoutSchedule
        self.createdDate = createdDate
    }
}

/// Pro bonus feature entry: Metal Weight & Cost Calculator.
struct BCProEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var metalType: String
    var weightGrams: String
    var pricePerGram: String
    var estimatedCost: String
    var createdDate: Date

    init(id: UUID = UUID(), metalType: String = "14k Gold", weightGrams: String = "3.2", pricePerGram: String = "65", estimatedCost: String = "208", createdDate: Date = Date()) {
        self.id = id
        self.metalType = metalType
        self.weightGrams = weightGrams
        self.pricePerGram = pricePerGram
        self.estimatedCost = estimatedCost
        self.createdDate = createdDate
    }
}

enum BCMetalTypeOption {
    static let all = ["Sterling Silver", "14k Gold", "18k Gold", "Bronze", "Fine Silver"]
}
