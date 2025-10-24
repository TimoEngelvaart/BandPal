import SwiftUI
import CloudKit

struct ShareView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer
    let band: Band

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(
            share: share,
            container: container
        )
        controller.delegate = context.coordinator
        controller.availablePermissions = [.allowReadWrite, .allowReadOnly]
        return controller
    }

    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(band: band)
    }

    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        let band: Band

        init(band: Band) {
            self.band = band
        }

        func cloudSharingController(
            _ csc: UICloudSharingController,
            failedToSaveShareWithError error: Error
        ) {
            print("Failed to save share: \(error)")
        }

        func itemTitle(for csc: UICloudSharingController) -> String? {
            return band.name
        }

        func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
            // You could return a thumbnail image here if you have one
            return nil
        }
    }
}
