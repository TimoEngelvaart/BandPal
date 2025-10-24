import Foundation
import SwiftData

@Model
final class BandMember: Equatable {
    var id: UUID = UUID() // CloudKit: removed unique constraint, added default
    var name: String = "" // CloudKit: added default value
    var instrument: String?
    var isActive: Bool = true // CloudKit: added default value

    @Relationship(deleteRule: .nullify, inverse: \Band.members)
    var band: Band?

    @Relationship(deleteRule: .nullify)
    var absentFromRehearsals: [Rehearsal]?

    // Equatable conformance for better SwiftUI performance
    static func == (lhs: BandMember, rhs: BandMember) -> Bool {
        lhs.id == rhs.id
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        instrument: String? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.instrument = instrument
        self.isActive = isActive
    }
}
