import Foundation
import SwiftData
import CloudKit

@Model
final class Band: Equatable {
    var id: UUID = UUID() // CloudKit: removed unique constraint, added default
    var name: String = "" // CloudKit: added default value
    var createdAt: Date = Date() // CloudKit: added default value
    var inviteCode: String? // For easy sharing

    // CloudKit sharing
    var shareRecord: Data? // Stores CKShare reference

    @Relationship(deleteRule: .cascade)
    var members: [BandMember]? // CloudKit: made optional

    @Relationship(deleteRule: .cascade)
    var setlists: [Setlist]? // CloudKit: made optional

    @Relationship(deleteRule: .cascade)
    var rehearsals: [Rehearsal]? // CloudKit: made optional

    // Equatable conformance
    static func == (lhs: Band, rhs: Band) -> Bool {
        lhs.id == rhs.id
    }

    // Generate a simple invite code
    static func generateInviteCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // Removed confusing chars
        return String((0..<6).map { _ in characters.randomElement()! })
    }

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        inviteCode: String? = nil
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.inviteCode = inviteCode ?? Band.generateInviteCode()
        self.members = []
        self.setlists = []
        self.rehearsals = []
    }
}
