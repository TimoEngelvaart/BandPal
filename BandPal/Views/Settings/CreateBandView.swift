import SwiftUI
import SwiftData

struct CreateBandView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var bandName = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "music.note.house.fill")
                        .font(.custom("Urbanist-Regular", size: 60))
                        .foregroundColor(.blue)

                    Text("Create Your Band")
                        .font(.custom("Urbanist-SemiBold", size: 24))

                    Text("Choose a name for your band. You can invite other musicians to collaborate.")
                        .font(.custom("Urbanist-Regular", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                // Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Band Name")
                        .font(.custom("Urbanist-SemiBold", size: 14))
                        .foregroundColor(.secondary)

                    TextField("Enter band name", text: $bandName)
                        .textFieldStyle(.plain)
                        .font(.custom("Urbanist-Regular", size: 16))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // Create Button
                Button {
                    createBand()
                } label: {
                    Text("Create Band")
                        .font(.custom("Urbanist-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(bandName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(bandName.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("New Band")
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

    private func createBand() {
        guard !bandName.isEmpty else { return }

        let newBand = Band(name: bandName.trimmingCharacters(in: .whitespacesAndNewlines))
        modelContext.insert(newBand)

        // Add default members
        let member1 = BandMember(name: "You", instrument: "")
        member1.band = newBand
        modelContext.insert(member1)

        do {
            try modelContext.save()

            // Register band in CloudKit so others can find it
            Task {
                do {
                    try await BandSharingManager.shared.registerBand(newBand)
                    // Also set up subscriptions for the owner
                    try await BandSharingManager.shared.setupSubscriptions(for: newBand)
                } catch {
                    print("Warning: Could not register band in CloudKit: \(error)")
                    // Don't show error to user - band still works locally
                }
            }

            dismiss()
        } catch {
            errorMessage = "Failed to create band: \(error.localizedDescription)"
            showError = true
        }
    }
}

#Preview {
    CreateBandView()
}
