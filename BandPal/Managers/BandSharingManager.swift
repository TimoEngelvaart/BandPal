import Foundation
import CloudKit
import SwiftData

/// Manages band sharing across different Apple IDs using CloudKit Public Database
@MainActor
class BandSharingManager: ObservableObject {
    static let shared = BandSharingManager()

    private let container: CKContainer
    private let publicDatabase: CKDatabase

    @Published var isProcessing = false
    @Published var error: String?

    private init() {
        self.container = CKContainer.default()
        self.publicDatabase = container.publicCloudDatabase
    }

    // MARK: - Register Band in Public Database

    /// Register a band in the public database so others can find it
    func registerBand(_ band: Band) async throws {
        isProcessing = true
        defer { isProcessing = false }

        // Get current user's ID
        let userID = try await container.userRecordID()

        // Create a record in public database
        let recordID = CKRecord.ID(recordName: "Band_\(band.inviteCode ?? "")")
        let record = CKRecord(recordType: "SharedBand", recordID: recordID)

        record["inviteCode"] = band.inviteCode as CKRecordValue?
        record["bandName"] = band.name as CKRecordValue
        record["ownerID"] = userID.recordName as CKRecordValue
        record["createdAt"] = band.createdAt as CKRecordValue
        record["bandID"] = band.id.uuidString as CKRecordValue

        // Save to public database
        _ = try await publicDatabase.save(record)

        print("✅ Band registered in CloudKit: \(band.inviteCode ?? "unknown")")
    }

    // MARK: - Find Band by Invite Code

    /// Search for a band using an invite code
    func findBand(withInviteCode code: String) async throws -> BandInfo? {
        isProcessing = true
        defer { isProcessing = false }

        // Query public database
        let predicate = NSPredicate(format: "inviteCode == %@", code)
        let query = CKQuery(recordType: "SharedBand", predicate: predicate)

        let (matchResults, _) = try await publicDatabase.records(matching: query, resultsLimit: 1)

        guard let firstMatch = matchResults.first,
              case .success(let record) = firstMatch.1 else {
            return nil
        }

        // Extract band info
        guard let bandName = record["bandName"] as? String,
              let ownerID = record["ownerID"] as? String,
              let bandID = record["bandID"] as? String,
              let createdAt = record["createdAt"] as? Date else {
            return nil
        }

        return BandInfo(
            id: UUID(uuidString: bandID) ?? UUID(),
            name: bandName,
            inviteCode: code,
            ownerID: ownerID,
            createdAt: createdAt
        )
    }

    // MARK: - Create Local Band from Shared Info

    /// Create a local copy of a shared band
    func createLocalBand(from bandInfo: BandInfo, in context: ModelContext) throws -> Band {
        // Check if already exists
        let inviteCode = bandInfo.inviteCode
        let fetchDescriptor = FetchDescriptor<Band>(
            predicate: #Predicate<Band> { band in
                band.inviteCode == inviteCode
            }
        )

        if let existingBand = try? context.fetch(fetchDescriptor).first {
            return existingBand
        }

        // Create new local band
        let newBand = Band(
            id: bandInfo.id,
            name: bandInfo.name,
            createdAt: bandInfo.createdAt,
            inviteCode: bandInfo.inviteCode
        )

        // Mark this band as shared (not the owner)
        newBand.shareRecord = "SHARED_BAND".data(using: .utf8)

        context.insert(newBand)
        try context.save()

        print("✅ Created local copy of band: \(bandInfo.name)")

        return newBand
    }

    // MARK: - Sync Changes

    /// Sync local band changes to CloudKit (called when band data changes)
    func syncBandChanges(_ band: Band) async throws {
        guard let inviteCode = band.inviteCode else { return }

        // Fetch the public record
        let recordID = CKRecord.ID(recordName: "Band_\(inviteCode)")

        do {
            let record = try await publicDatabase.record(for: recordID)

            // Update fields
            record["bandName"] = band.name as CKRecordValue
            record["lastModified"] = Date() as CKRecordValue

            // Save changes
            _ = try await publicDatabase.save(record)

            print("✅ Synced band changes to CloudKit")
        } catch {
            print("⚠️ Could not sync band changes: \(error.localizedDescription)")
        }
    }

    // MARK: - Check Ownership

    /// Check if current user is the owner of a band
    func isOwner(of band: Band) async -> Bool {
        guard let inviteCode = band.inviteCode,
              band.shareRecord == nil else {
            return true // Local band, user is owner
        }

        do {
            let userID = try await container.userRecordID()
            let recordID = CKRecord.ID(recordName: "Band_\(inviteCode)")
            let record = try await publicDatabase.record(for: recordID)

            if let ownerID = record["ownerID"] as? String {
                return ownerID == userID.recordName
            }
        } catch {
            print("Could not check ownership: \(error)")
        }

        return false
    }

    // MARK: - Sync Setlists

    /// Push a setlist to CloudKit for sharing
    func syncSetlist(_ setlist: Setlist, for band: Band) async throws {
        guard let inviteCode = band.inviteCode else { return }

        let recordID = CKRecord.ID(recordName: "Setlist_\(setlist.id.uuidString)")
        let record = CKRecord(recordType: "SharedSetlist", recordID: recordID)

        record["bandCode"] = inviteCode as CKRecordValue
        record["setlistID"] = setlist.id.uuidString as CKRecordValue
        record["title"] = setlist.title as CKRecordValue
        record["date"] = setlist.date as CKRecordValue
        record["venue"] = setlist.venue as CKRecordValue?
        record["targetDuration"] = (setlist.targetDuration ?? 0) as CKRecordValue

        // Store songs as JSON
        let songsData = try JSONEncoder().encode((setlist.songs ?? []).map { SongData(from: $0) })
        record["songsData"] = String(data: songsData, encoding: .utf8) as CKRecordValue?

        _ = try await publicDatabase.save(record)
        print("✅ Synced setlist to CloudKit: \(setlist.title)")
    }

    /// Fetch all setlists for a band
    func fetchSetlists(for band: Band, context: ModelContext) async throws {
        guard let inviteCode = band.inviteCode else { return }

        let predicate = NSPredicate(format: "bandCode == %@", inviteCode)
        let query = CKQuery(recordType: "SharedSetlist", predicate: predicate)

        let (results, _) = try await publicDatabase.records(matching: query)

        for result in results {
            guard case .success(let record) = result.1,
                  let setlistID = record["setlistID"] as? String,
                  let title = record["title"] as? String,
                  let date = record["date"] as? Date else {
                continue
            }

            // Check if already exists locally
            let uuid = UUID(uuidString: setlistID) ?? UUID()
            let fetchDescriptor = FetchDescriptor<Setlist>(
                predicate: #Predicate<Setlist> { $0.id == uuid }
            )

            if (try? context.fetch(fetchDescriptor).first) != nil {
                continue // Already have this setlist
            }

            // Create new setlist
            let newSetlist = Setlist(
                id: uuid,
                title: title,
                date: date,
                songs: [],
                targetDuration: record["targetDuration"] as? Int,
                venue: record["venue"] as? String
            )
            // Temporarily disabled until Band model is fixed for CloudKit
            // newSetlist.band = band

            // Decode songs if available
            if let songsJSON = record["songsData"] as? String,
               let songsData = songsJSON.data(using: .utf8),
               let decodedSongs = try? JSONDecoder().decode([SongData].self, from: songsData) {
                var songsList = newSetlist.songs ?? []
                for songData in decodedSongs {
                    let song = songData.toSong(context: context)
                    songsList.append(song)
                }
                newSetlist.songs = songsList
            }

            context.insert(newSetlist)
        }

        try context.save()
        print("✅ Fetched setlists from CloudKit")
    }

    // MARK: - Sync Rehearsals

    /// Push a rehearsal to CloudKit
    func syncRehearsal(_ rehearsal: Rehearsal, for band: Band) async throws {
        guard let inviteCode = band.inviteCode else { return }

        let recordID = CKRecord.ID(recordName: "Rehearsal_\(rehearsal.id.uuidString)")
        let record = CKRecord(recordType: "SharedRehearsal", recordID: recordID)

        record["bandCode"] = inviteCode as CKRecordValue
        record["rehearsalID"] = rehearsal.id.uuidString as CKRecordValue
        record["date"] = rehearsal.date as CKRecordValue
        record["notes"] = rehearsal.notes as CKRecordValue?

        // Store new songs as JSON
        if let newSongs = rehearsal.newSongs {
            let newSongsData = try JSONEncoder().encode(newSongs.map { SongData(from: $0) })
            record["newSongsData"] = String(data: newSongsData, encoding: .utf8) as CKRecordValue?
        }

        // Store old songs as JSON
        if let oldSongs = rehearsal.oldSongs {
            let oldSongsData = try JSONEncoder().encode(oldSongs.map { SongData(from: $0) })
            record["oldSongsData"] = String(data: oldSongsData, encoding: .utf8) as CKRecordValue?
        }

        // Store absent members as JSON
        if let absentMembers = rehearsal.absentMembers {
            let membersData = try JSONEncoder().encode(absentMembers.map { MemberData(from: $0) })
            record["absentMembersData"] = String(data: membersData, encoding: .utf8) as CKRecordValue?
        }

        _ = try await publicDatabase.save(record)
        print("✅ Synced rehearsal to CloudKit with songs and members")
    }

    /// Fetch all rehearsals for a band
    func fetchRehearsals(for band: Band, context: ModelContext) async throws {
        guard let inviteCode = band.inviteCode else { return }

        let predicate = NSPredicate(format: "bandCode == %@", inviteCode)
        let query = CKQuery(recordType: "SharedRehearsal", predicate: predicate)

        let (results, _) = try await publicDatabase.records(matching: query)

        for result in results {
            guard case .success(let record) = result.1,
                  let rehearsalID = record["rehearsalID"] as? String,
                  let date = record["date"] as? Date else {
                continue
            }

            // Check if already exists
            let uuid = UUID(uuidString: rehearsalID) ?? UUID()
            let fetchDescriptor = FetchDescriptor<Rehearsal>(
                predicate: #Predicate<Rehearsal> { $0.id == uuid }
            )

            if (try? context.fetch(fetchDescriptor).first) != nil {
                continue
            }

            // Decode songs and members
            var newSongs: [Song] = []
            var oldSongs: [Song] = []
            var absentMembers: [BandMember] = []

            // Decode new songs
            if let newSongsJSON = record["newSongsData"] as? String,
               let newSongsData = newSongsJSON.data(using: .utf8),
               let decodedNewSongs = try? JSONDecoder().decode([SongData].self, from: newSongsData) {
                newSongs = decodedNewSongs.map { $0.toSong(context: context) }
            }

            // Decode old songs
            if let oldSongsJSON = record["oldSongsData"] as? String,
               let oldSongsData = oldSongsJSON.data(using: .utf8),
               let decodedOldSongs = try? JSONDecoder().decode([SongData].self, from: oldSongsData) {
                oldSongs = decodedOldSongs.map { $0.toSong(context: context) }
            }

            // Decode absent members
            if let membersJSON = record["absentMembersData"] as? String,
               let membersData = membersJSON.data(using: .utf8),
               let decodedMembers = try? JSONDecoder().decode([MemberData].self, from: membersData) {
                absentMembers = decodedMembers.map { $0.toMember(context: context) }
            }

            // Create new rehearsal
            let newRehearsal = Rehearsal(
                id: uuid,
                date: date,
                absentMembers: absentMembers,
                notes: record["notes"] as? String,
                newSongs: newSongs,
                oldSongs: oldSongs
            )
            newRehearsal.band = band
            context.insert(newRehearsal)
        }

        try context.save()
        print("✅ Fetched rehearsals from CloudKit with songs and members")
    }

    // MARK: - Subscription Setup

    /// Set up CloudKit subscriptions to get notified of changes
    func setupSubscriptions(for band: Band) async throws {
        guard let inviteCode = band.inviteCode else { return }

        // Subscribe to setlists
        let setlistPredicate = NSPredicate(format: "bandCode == %@", inviteCode)
        let setlistSubscription = CKQuerySubscription(
            recordType: "SharedSetlist",
            predicate: setlistPredicate,
            subscriptionID: "setlists_\(inviteCode)",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )

        let setlistNotification = CKSubscription.NotificationInfo()
        setlistNotification.shouldSendContentAvailable = true
        setlistSubscription.notificationInfo = setlistNotification

        // Subscribe to rehearsals
        let rehearsalPredicate = NSPredicate(format: "bandCode == %@", inviteCode)
        let rehearsalSubscription = CKQuerySubscription(
            recordType: "SharedRehearsal",
            predicate: rehearsalPredicate,
            subscriptionID: "rehearsals_\(inviteCode)",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )

        let rehearsalNotification = CKSubscription.NotificationInfo()
        rehearsalNotification.shouldSendContentAvailable = true
        rehearsalSubscription.notificationInfo = rehearsalNotification

        // Save subscriptions
        _ = try await publicDatabase.save(setlistSubscription)
        _ = try await publicDatabase.save(rehearsalSubscription)

        print("✅ Subscriptions set up for band: \(band.name)")
    }

    // MARK: - Full Sync

    /// Perform a full sync for a band (fetch all data)
    func performFullSync(for band: Band, context: ModelContext) async throws {
        try await fetchSetlists(for: band, context: context)
        try await fetchRehearsals(for: band, context: context)
        print("✅ Full sync completed for band: \(band.name)")
    }
}

// MARK: - Supporting Types

struct BandInfo {
    let id: UUID
    let name: String
    let inviteCode: String
    let ownerID: String
    let createdAt: Date
}

// Helper struct for serializing songs
struct SongData: Codable {
    let id: String
    let title: String
    let artist: String
    let albumArt: String?
    let songDuration: Int?

    init(from song: Song) {
        self.id = song.id.uuidString
        self.title = song.title
        self.artist = song.artist
        self.albumArt = song.albumArt
        self.songDuration = song.songDuration
    }

    func toSong(context: ModelContext) -> Song {
        // Check if song already exists
        let uuid = UUID(uuidString: id) ?? UUID()

        // Try to fetch existing song
        if let existingSong = (try? context.fetch(FetchDescriptor<Song>()))?.first(where: { $0.id == uuid }) {
            return existingSong
        }

        // Create new song
        let song = Song(
            id: uuid,
            title: title,
            artist: artist,
            albumArt: albumArt,
            songDuration: songDuration
        )
        context.insert(song)
        return song
    }
}

// Helper struct for serializing band members
struct MemberData: Codable {
    let id: String
    let name: String
    let instrument: String?

    init(from member: BandMember) {
        self.id = member.id.uuidString
        self.name = member.name
        self.instrument = member.instrument
    }

    func toMember(context: ModelContext) -> BandMember {
        // Check if member already exists
        let uuid = UUID(uuidString: id) ?? UUID()

        // Try to fetch existing member
        if let existingMember = (try? context.fetch(FetchDescriptor<BandMember>()))?.first(where: { $0.id == uuid }) {
            return existingMember
        }

        // Create new member
        let member = BandMember(
            id: uuid,
            name: name,
            instrument: instrument ?? ""
        )
        context.insert(member)
        return member
    }
}
