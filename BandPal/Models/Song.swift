import Foundation
import SwiftData

// Enums for Song metadata
enum SongSortOption: String, CaseIterable, Hashable {
    case title = "Title (A-Z)"
    case duration = "Duration"

    var icon: String {
        switch self {
        case .title: return "textformat.abc"
        case .duration: return "clock"
        }
    }
}

@Model
final class Song: Equatable {
    var id: UUID = UUID() // CloudKit: removed unique constraint, added default
    var title: String = "" // CloudKit: added default
    var artist: String = "" // CloudKit: added default
    var albumArt: String?
    var songDuration: Int? // Duration in milliseconds
    var isManualDuration: Bool = false

    // Coverband-specific metadata
    var lastPerformed: Date?
    var bpm: Int?
    var musicalKey: String?
    var audienceRating: Double? // 1-5 stars
    var arrangementNotes: String? // "Capo 2", "Skip bridge", etc.

    @Relationship(deleteRule: .nullify, inverse: \Setlist.songs)
    var setlist: Setlist?

    @Relationship(deleteRule: .nullify)
    var newSongRehearsals: [Rehearsal]?

    @Relationship(deleteRule: .nullify)
    var oldSongRehearsals: [Rehearsal]?

    // Static cached calendar for performance
    private static let calendar = Calendar.current

    // Equatable conformance for better SwiftUI performance
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }

    var formattedDuration: String {
        guard let duration = songDuration, duration > 0 else {
            return "Duration not available"
        }
        let totalSeconds = duration / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var daysSinceLastPerformed: Int? {
        guard let lastPerformed = lastPerformed else { return nil }
        return Self.calendar.dateComponents([.day], from: lastPerformed, to: Date()).day
    }

    var lastPerformedText: String {
        guard let days = daysSinceLastPerformed else { return "Never performed" }
        if days == 0 { return "Played today" }
        if days == 1 { return "Played yesterday" }
        return "Played \(days) days ago"
    }

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        albumArt: String? = nil,
        songDuration: Int? = nil,
        isManualDuration: Bool = false,
        lastPerformed: Date? = nil,
        bpm: Int? = nil,
        musicalKey: String? = nil,
        audienceRating: Double? = nil,
        arrangementNotes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.albumArt = albumArt
        self.songDuration = songDuration
        self.isManualDuration = isManualDuration
        self.lastPerformed = lastPerformed
        self.bpm = bpm
        self.musicalKey = musicalKey
        self.audienceRating = audienceRating
        self.arrangementNotes = arrangementNotes
    }
}
