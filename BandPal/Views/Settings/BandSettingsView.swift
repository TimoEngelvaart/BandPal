import SwiftUI
import SwiftData

struct BandSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var bands: [Band]
    @AppStorage("activeBandID") private var activeBandID: String = ""

    var band: Band? = nil  // Optional: can be passed in directly

    // Get the band to display
    private var currentBand: Band? {
        // Use passed band if available, otherwise get active band
        if let providedBand = band {
            return providedBand
        }
        return bands.first { $0.id.uuidString == activeBandID }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let band = currentBand {
                    // Band Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Band Information")
                            .font(.custom("Urbanist-SemiBold", size: 18))
                            .padding(.horizontal, 16)
                            .padding(.top, 24)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Name:")
                                    .font(.custom("Urbanist-SemiBold", size: 16))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(band.name)
                                    .font(.custom("Urbanist-Regular", size: 16))
                            }

                            Divider()

                            HStack {
                                Text("Created:")
                                    .font(.custom("Urbanist-SemiBold", size: 16))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(band.createdAt, style: .date)
                                    .font(.custom("Urbanist-Regular", size: 16))
                            }

                            Divider()

                            HStack {
                                Text("Members:")
                                    .font(.custom("Urbanist-SemiBold", size: 16))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\((band.members ?? []).count)")
                                    .font(.custom("Urbanist-Regular", size: 16))
                            }

                            Divider()

                            HStack {
                                Text("Setlists:")
                                    .font(.custom("Urbanist-SemiBold", size: 16))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\((band.setlists ?? []).count)")
                                    .font(.custom("Urbanist-Regular", size: 16))
                            }

                            if band.shareRecord != nil {
                                Divider()

                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(.blue)
                                    Text("Shared with others")
                                        .font(.custom("Urbanist-Regular", size: 14))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }

                    // Share Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Collaboration")
                            .font(.custom("Urbanist-SemiBold", size: 18))
                            .padding(.horizontal, 16)
                            .padding(.top, 32)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("Share your band with other musicians to collaborate on setlists, songs, and rehearsals.")
                                .font(.custom("Urbanist-Regular", size: 14))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            // Invite Code Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Band Invite Code")
                                    .font(.custom("Urbanist-SemiBold", size: 14))
                                    .foregroundColor(.secondary)

                                HStack {
                                    Text(band.inviteCode ?? "N/A")
                                        .font(.custom("Urbanist-SemiBold", size: 24))
                                        .tracking(2)

                                    Spacer()

                                    Button {
                                        if let code = band.inviteCode {
                                            UIPasteboard.general.string = code
                                        }
                                    } label: {
                                        Image(systemName: "doc.on.doc")
                                            .font(.custom("Urbanist-Regular", size: 20))
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                            }

                            Text("Share this code with band members so they can join your band and collaborate on setlists.")
                                .font(.custom("Urbanist-Regular", size: 12))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)

                            // Share Button
                            Button {
                                shareInviteCode(band: band)
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Invite Code")
                                }
                                .font(.custom("Urbanist-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }

                    Spacer()
                } else {
                    // No band selected
                    VStack(spacing: 24) {
                        Spacer()

                        Image(systemName: "music.note.house")
                            .font(.custom("Urbanist-Regular", size: 60))
                            .foregroundColor(.secondary)

                        VStack(spacing: 8) {
                            Text("No Band Selected")
                                .font(.custom("Urbanist-SemiBold", size: 18))
                            Text("Create or join a band from the band list")
                                .font(.custom("Urbanist-Regular", size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Band Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Functions

    private func shareInviteCode(band: Band) {
        guard let code = band.inviteCode else { return }

        let message = """
        Join my band "\(band.name)" on BandPal!

        Invite Code: \(code)

        Download BandPal and enter this code to collaborate on setlists, songs, and rehearsals together.
        """

        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            // Find the presented view controller
            var presentedVC = rootViewController
            while let presented = presentedVC.presentedViewController {
                presentedVC = presented
            }
            activityVC.popoverPresentationController?.sourceView = presentedVC.view
            presentedVC.present(activityVC, animated: true)
        }
    }

}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Band.self, BandMember.self, Setlist.self, configurations: config)

    let band = Band(name: "Test Band")
    container.mainContext.insert(band)

    return BandSettingsView()
        .modelContainer(container)
}
