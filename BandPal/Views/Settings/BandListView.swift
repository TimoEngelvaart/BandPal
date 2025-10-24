import SwiftUI
import SwiftData

struct BandListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Band.createdAt, order: .reverse) private var bands: [Band]

    @State private var showCreateBand = false
    @State private var showJoinBand = false
    @State private var selectedBandForSettings: Band?
    @AppStorage("activeBandID") private var activeBandID: String = ""

    var activeBand: Band? {
        bands.first { $0.id.uuidString == activeBandID }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if bands.isEmpty {
                    // No bands - show empty state
                    VStack(spacing: 24) {
                        Spacer()

                        Image(systemName: "music.note.house")
                            .font(.custom("Urbanist-Regular", size: 60))
                            .foregroundColor(.secondary)

                        VStack(spacing: 8) {
                            Text("No Bands Yet")
                                .font(.custom("Urbanist-SemiBold", size: 20))

                            Text("Create a new band or join an existing one to get started")
                                .font(.custom("Urbanist-Regular", size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }

                        Spacer()

                        VStack(spacing: 12) {
                            Button {
                                showCreateBand = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create Band")
                                }
                                .font(.custom("Urbanist-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }

                            Button {
                                showJoinBand = true
                            } label: {
                                HStack {
                                    Image(systemName: "person.badge.key.fill")
                                    Text("Join Band")
                                }
                                .font(.custom("Urbanist-SemiBold", size: 16))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                } else {
                    // Show band list
                    List {
                        ForEach(bands) { band in
                            BandRowView(
                                band: band,
                                isActive: band.id.uuidString == activeBandID,
                                onSelect: {
                                    activeBandID = band.id.uuidString
                                    dismiss()
                                },
                                onInfo: {
                                    selectedBandForSettings = band
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteBands)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("My Bands")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                if !bands.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                showCreateBand = true
                            } label: {
                                Label("Create Band", systemImage: "plus.circle")
                            }

                            Button {
                                showJoinBand = true
                            } label: {
                                Label("Join Band", systemImage: "person.badge.key")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateBand) {
                CreateBandView()
            }
            .sheet(isPresented: $showJoinBand) {
                JoinBandView()
            }
            .sheet(item: $selectedBandForSettings) { band in
                BandSettingsView(band: band)
            }
        }
    }

    private func deleteBands(at offsets: IndexSet) {
        for index in offsets {
            let band = bands[index]

            // If deleting active band, clear active band
            if band.id.uuidString == activeBandID {
                activeBandID = ""
            }

            modelContext.delete(band)
        }
    }
}

struct BandRowView: View {
    let band: Band
    let isActive: Bool
    let onSelect: () -> Void
    let onInfo: () -> Void

    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack(spacing: 16) {
                // Band Icon
                ZStack {
                    Circle()
                        .fill(isActive ? Color.blue : Color(.systemGray5))
                        .frame(width: 50, height: 50)

                    Image(systemName: "music.note")
                        .font(.custom("Urbanist-SemiBold", size: 20))
                        .foregroundColor(isActive ? .white : .secondary)
                }

                // Band Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(band.name)
                        .font(.custom("Urbanist-SemiBold", size: 16))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2")
                                .font(.custom("Urbanist-Regular", size: 10))
                            Text("\((band.members ?? []).count)")
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "music.note.list")
                                .font(.custom("Urbanist-Regular", size: 10))
                            Text("\((band.setlists ?? []).count)")
                        }
                    }
                    .font(.custom("Urbanist-Regular", size: 12))
                    .foregroundColor(.secondary)
                }

                Spacer()

                // Active Badge and Info Button in VStack
                VStack(spacing: 8) {
                    if isActive {
                        Text("Active")
                            .font(.custom("Urbanist-SemiBold", size: 11))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(6)
                    }

                    Button {
                        onInfo()
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.custom("Urbanist-Regular", size: 22))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? Color.blue : Color.gray.opacity(0.2), lineWidth: isActive ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Band.self, configurations: config)

    let band1 = Band(name: "Rock Stars")
    let band2 = Band(name: "Jazz Quartet")
    container.mainContext.insert(band1)
    container.mainContext.insert(band2)

    return BandListView()
        .modelContainer(container)
}
