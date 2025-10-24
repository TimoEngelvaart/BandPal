import Foundation
import SwiftData

enum DurationStatus: String {
    case underTarget = "Under Target"
    case onTarget = "On Target"
    case overTarget = "Over Target"
    case noTarget = "No Target Set"
}

@Model
final class Setlist: Equatable {
    var id: UUID = UUID() // CloudKit: removed unique constraint, added default
    var title: String = "" // CloudKit: added default
    var date: Date = Date() // CloudKit: added default
    var targetDuration: Int? // Target duration in seconds
    var venue: String?
    var notes: String?

    // Performance tracking
    var isPerformed: Bool = false
    var performanceDate: Date?
    var performanceVenue: String?
    var performanceNotes: String?

    @Relationship(deleteRule: .cascade)
    var songs: [Song]? // CloudKit: made optional

    @Relationship(deleteRule: .nullify, inverse: \Band.setlists)
    var band: Band? // CloudKit: added inverse

    // Static cached calendar for performance
    private static let calendar = Calendar.current

    // Equatable conformance
    static func == (lhs: Setlist, rhs: Setlist) -> Bool {
        lhs.id == rhs.id
    }

    // Computed properties for duration tracking
    var totalDurationInSeconds: Int {
        (songs ?? []).compactMap { $0.songDuration }.reduce(0, +) / 1000
    }

    var formattedTotalDuration: String {
        let totalSeconds = totalDurationInSeconds
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var formattedTargetDuration: String {
        guard let target = targetDuration else { return "No target" }
        let minutes = target / 60
        let seconds = target % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var durationStatus: DurationStatus {
        guard let target = targetDuration else { return .noTarget }
        let total = totalDurationInSeconds

        let difference = abs(total - target)
        let tolerance = target / 20 // 5% tolerance

        if difference <= tolerance {
            return .onTarget
        } else if total < target {
            return .underTarget
        } else {
            return .overTarget
        }
    }

    var progressPercentage: Double {
        guard let target = targetDuration, target > 0 else { return 0 }
        let total = Double(totalDurationInSeconds)
        return min((total / Double(target)) * 100, 100)
    }

    var durationDifference: String {
        guard let target = targetDuration else { return "" }
        let difference = totalDurationInSeconds - target
        let absDifference = abs(difference)
        let minutes = absDifference / 60
        let seconds = absDifference % 60

        if difference > 0 {
            return "+\(String(format: "%d:%02d", minutes, seconds))"
        } else if difference < 0 {
            return "-\(String(format: "%d:%02d", minutes, seconds))"
        } else {
            return "0:00"
        }
    }

    // Methods
    func markAsPerformed(on date: Date, venue: String?, notes: String?) {
        self.isPerformed = true
        self.performanceDate = date
        self.performanceVenue = venue
        self.performanceNotes = notes
    }

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        songs: [Song] = [],
        targetDuration: Int? = nil,
        venue: String? = nil,
        notes: String? = nil,
        isPerformed: Bool = false,
        performanceDate: Date? = nil,
        performanceVenue: String? = nil,
        performanceNotes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.songs = songs
        self.targetDuration = targetDuration
        self.venue = venue
        self.notes = notes
        self.isPerformed = isPerformed
        self.performanceDate = performanceDate
        self.performanceVenue = performanceVenue
        self.performanceNotes = performanceNotes
    }
}
