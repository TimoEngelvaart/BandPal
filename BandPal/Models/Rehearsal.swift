import Foundation
import SwiftData

@Model
final class Rehearsal: Equatable {
    var id: UUID = UUID() // CloudKit: removed unique constraint, added default
    var date: Date = Date() // CloudKit: added default value
    var notes: String?
    var recordingLink: String?

    // Relationships to songs
    @Relationship(deleteRule: .nullify, inverse: \Song.newSongRehearsals)
    var newSongs: [Song]?

    @Relationship(deleteRule: .nullify, inverse: \Song.oldSongRehearsals)
    var oldSongs: [Song]?

    // Relationships to band members
    @Relationship(deleteRule: .nullify, inverse: \BandMember.absentFromRehearsals)
    var absentMembers: [BandMember]?

    @Relationship(deleteRule: .nullify, inverse: \Band.rehearsals)
    var band: Band? // CloudKit: already optional ✓

    // Static cached formatter for performance
    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    // Equatable conformance for better SwiftUI performance
    static func == (lhs: Rehearsal, rhs: Rehearsal) -> Bool {
        lhs.id == rhs.id
    }

    // Computed properties
    var formattedDate: String {
        Self.displayFormatter.string(from: date)
    }

    var isPast: Bool {
        date < Date()
    }

    var totalSongs: Int {
        (newSongs?.count ?? 0) + (oldSongs?.count ?? 0)
    }

    init(
        id: UUID = UUID(),
        date: Date,
        absentMembers: [BandMember]? = [],
        notes: String? = nil,
        recordingLink: String? = nil,
        newSongs: [Song]? = [],
        oldSongs: [Song]? = []
    ) {
        self.id = id
        self.date = date
        self.absentMembers = absentMembers
        self.notes = notes
        self.recordingLink = recordingLink
        self.newSongs = newSongs
        self.oldSongs = oldSongs
    }
}
