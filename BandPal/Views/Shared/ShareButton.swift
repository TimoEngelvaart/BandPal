import SwiftUI
import CloudKit
import SwiftData

struct ShareButton: View {
    let band: Band
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = BandSharingViewModel()

    var body: some View {
        Button {
            Task {
                await viewModel.prepareSharingSheet(for: band, context: modelContext)
            }
        } label: {
            if viewModel.isSharing {
                ProgressView()
            } else {
                Label(
                    viewModel.isShared(band: band) ? "Manage Share" : "Share Band",
                    systemImage: viewModel.isShared(band: band) ? "person.2.fill" : "person.2"
                )
            }
        }
        .disabled(viewModel.isSharing)
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let share = viewModel.currentShare {
                ShareView(
                    share: share,
                    container: CKContainer.default(),
                    band: band
                )
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Band.self, configurations: config)

    let band = Band(name: "Test Band")
    container.mainContext.insert(band)

    return ShareButton(band: band)
        .modelContainer(container)
}
