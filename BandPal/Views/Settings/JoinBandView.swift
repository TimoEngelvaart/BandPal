import SwiftUI
import SwiftData

struct JoinBandView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var bands: [Band]

    @State private var inviteCode = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.2.badge.key.fill")
                        .font(.custom("Urbanist-Regular", size: 60))
                        .foregroundColor(.green)

                    Text("Join a Band")
                        .font(.custom("Urbanist-SemiBold", size: 24))

                    Text("Enter the invite code shared by your band leader to join and start collaborating.")
                        .font(.custom("Urbanist-Regular", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                // Invite Code Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Invite Code")
                        .font(.custom("Urbanist-SemiBold", size: 14))
                        .foregroundColor(.secondary)

                    TextField("Enter 6-character code", text: $inviteCode)
                        .textFieldStyle(.plain)
                        .font(.custom("Urbanist-SemiBold", size: 24))
                        .tracking(2)
                        .textCase(.uppercase)
                        .autocapitalization(.allCharacters)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .onChange(of: inviteCode) { oldValue, newValue in
                            // Limit to 6 characters and uppercase
                            inviteCode = String(newValue.uppercased().prefix(6))
                        }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                if isSearching {
                    ProgressView()
                        .padding()
                }

                Spacer()

                // Join Button
                Button {
                    joinBand()
                } label: {
                    HStack {
                        if isSearching {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isSearching ? "Searching..." : "Join Band")
                    }
                    .font(.custom("Urbanist-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(inviteCode.count == 6 && !isSearching ? Color.green : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(inviteCode.count != 6 || isSearching)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Join Band")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func joinBand() {
        guard inviteCode.count == 6 else { return }

        isSearching = true

        Task {
            do {
                // First check if already a member locally
                if let localBand = bands.first(where: { $0.inviteCode == inviteCode }) {
                    isSearching = false
                    errorMessage = "You're already a member of \(localBand.name)!"
                    showError = true
                    return
                }

                // Search CloudKit for band with this invite code
                guard let bandInfo = try await BandSharingManager.shared.findBand(withInviteCode: inviteCode) else {
                    isSearching = false
                    errorMessage = "No band found with code '\(inviteCode)'. Please check the code and try again."
                    showError = true
                    return
                }

                // Create local copy of the band
                let joinedBand = try BandSharingManager.shared.createLocalBand(from: bandInfo, in: modelContext)

                // Add yourself as a member
                let member = BandMember(name: "You", instrument: "")
                member.band = joinedBand
                modelContext.insert(member)
                try modelContext.save()

                // Set up subscriptions for this band
                try await BandSharingManager.shared.setupSubscriptions(for: joinedBand)

                // Perform initial sync to get existing data
                try await BandSharingManager.shared.performFullSync(for: joinedBand, context: modelContext)

                isSearching = false

                // Success! Dismiss the sheet
                dismiss()
            } catch {
                isSearching = false
                errorMessage = "Failed to join band: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

#Preview {
    JoinBandView()
}
