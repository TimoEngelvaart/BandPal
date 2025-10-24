import Foundation
import CloudKit
import SwiftData

@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()

    private let container: CKContainer
    private let privateDatabase: CKDatabase

    @Published var isSignedIntoiCloud = false
    @Published var shareInProgress = false

    private init() {
        self.container = CKContainer.default()
        self.privateDatabase = container.privateCloudDatabase

        // Check iCloud status
        Task {
            await checkiCloudStatus()
        }
    }

    // MARK: - iCloud Status

    func checkiCloudStatus() async {
        do {
            let status = try await container.accountStatus()
            isSignedIntoiCloud = (status == .available)
        } catch {
            print("Error checking iCloud status: \(error)")
            isSignedIntoiCloud = false
        }
    }

    // MARK: - Share Creation

    /// Create a share for a Band object
    func createShare(for band: Band, context: ModelContext) async throws -> CKShare {
        // Get the persistent identifier for the band
        let bandID = band.id

        // Create a CKShare
        let share = CKShare(rootRecord: CKRecord(recordType: "Band", recordID: CKRecord.ID(recordName: bandID.uuidString)))
        share[CKShare.SystemFieldKey.title] = band.name as CKRecordValue

        // Configure share permissions
        share.publicPermission = .none // Private sharing only

        // Save the share to CloudKit
        do {
            let savedShare = try await privateDatabase.save(share)

            // Store the share reference in the band
            if let shareData = try? NSKeyedArchiver.archivedData(withRootObject: savedShare.recordID, requiringSecureCoding: true) {
                band.shareRecord = shareData
                try context.save()
            }

            return savedShare
        } catch {
            print("Error creating share: \(error)")
            throw error
        }
    }

    /// Get existing share for a band
    func fetchShare(for band: Band) async throws -> CKShare? {
        guard let shareData = band.shareRecord,
              let recordID = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKRecord.ID.self, from: shareData) else {
            return nil
        }

        do {
            let record = try await privateDatabase.record(for: recordID)
            return record as? CKShare
        } catch {
            print("Error fetching share: \(error)")
            return nil
        }
    }

    /// Stop sharing a band
    func removeShare(for band: Band, context: ModelContext) async throws {
        guard let shareData = band.shareRecord,
              let recordID = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKRecord.ID.self, from: shareData) else {
            return
        }

        do {
            _ = try await privateDatabase.deleteRecord(withID: recordID)
            band.shareRecord = nil
            try context.save()
        } catch {
            print("Error removing share: \(error)")
            throw error
        }
    }

    // MARK: - Share Participants

    /// Get all participants of a share
    func fetchParticipants(for share: CKShare) async throws -> [CKShare.Participant] {
        return share.participants
    }

    /// Remove a participant from a share
    func removeParticipant(_ participant: CKShare.Participant, from share: CKShare) async throws {
        share.removeParticipant(participant)
        _ = try await privateDatabase.save(share)
    }

    // MARK: - Share Acceptance

    /// Accept a share invitation
    func acceptShare(metadata: CKShare.Metadata) async throws -> CKShare {
        let share = try await container.accept(metadata)
        return share
    }

    // MARK: - Sync

    /// Fetch changes from CloudKit
    func fetchChanges() async throws {
        // This would be used to sync changes from other participants
        // For now, SwiftData with CloudKit handles most of this automatically
        print("Fetching CloudKit changes...")
    }

    // MARK: - Helper Methods

    /// Generate a shareable URL from a share
    func generateShareURL(from share: CKShare) -> URL? {
        return share.url
    }

    /// Check if current user is the owner of a share
    func isOwner(of share: CKShare) -> Bool {
        return share.owner == share.currentUserParticipant
    }

    /// Check if current user can edit
    func canEdit(share: CKShare) -> Bool {
        guard let participant = share.currentUserParticipant else { return false }
        return participant.permission == .readWrite
    }
}

// MARK: - Error Handling

enum CloudKitError: LocalizedError {
    case notSignedIn
    case networkUnavailable
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Please sign in to iCloud to share bands with others."
        case .networkUnavailable:
            return "Network connection unavailable. Please check your internet connection."
        case .unknownError(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}
