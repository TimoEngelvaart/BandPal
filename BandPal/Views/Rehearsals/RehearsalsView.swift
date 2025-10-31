import SwiftUI
import SwiftData

struct RehearsalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Query(sort: \Rehearsal.date, order: .forward) private var allRehearsals: [Rehearsal]
    @Query private var bands: [Band]
    @AppStorage("activeBandID") private var activeBandID: String = ""
    @State private var selectedStatus: String = "Upcoming"
    @State private var selectedRehearsal: Rehearsal?
    @State private var showBandList = false
    @State private var searchText = ""
    @State private var isSearching = false
    @Binding var selectedTab: Int

    // Get active band
    private var activeBand: Band? {
        bands.first { $0.id.uuidString == activeBandID }
    }

    // Filter rehearsals by active band
    private var rehearsals: [Rehearsal] {
        guard let activeBand = activeBand else { return [] }
        return allRehearsals.filter { $0.band?.id == activeBand.id }
    }

    var filteredRehearsals: [Rehearsal] {
        // Get today at midnight for accurate date comparison
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var filtered: [Rehearsal]

        switch selectedStatus {
        case "Upcoming":
            filtered = rehearsals.filter { $0.date >= today }
        case "Completed":
            filtered = rehearsals.filter { $0.date < today }
        default:
            filtered = rehearsals
        }

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { rehearsal in
                // Search in notes
                (rehearsal.notes?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                // Search in absent member names
                (rehearsal.absentMembers ?? []).contains { $0.name.localizedCaseInsensitiveContains(searchText) } ||
                // Search in new song titles
                (rehearsal.newSongs ?? []).contains { $0.title.localizedCaseInsensitiveContains(searchText) } ||
                // Search in old song titles
                (rehearsal.oldSongs ?? []).contains { $0.title.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return filtered
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
            // Header with search and settings icons
            if !isSearching {
                HStack {
                    Text("Rehearsals")
                        .font(.custom("Urbanist-SemiBold", size: 24))
                    Spacer()
                    HStack(spacing: 16) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isSearching = true
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.custom("Urbanist-Regular", size: 22))
                                .foregroundColor(.primary)
                        }

                        Button {
                            showBandList = true
                        } label: {
                            Image(systemName: "person.2")
                                .font(.custom("Urbanist-Regular", size: 22))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .frame(minHeight: 48, maxHeight: 48)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .transition(.opacity)
            }

            // Search bar
            if isSearching {
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.6) : Color(red: 0.62, green: 0.62, blue: 0.62))
                            .font(.custom("Urbanist-Regular", size: 16))

                        TextField("Search rehearsals...", text: $searchText)
                            .font(.custom("Urbanist-SemiBold", size: 14))
                            .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
                            .autocorrectionDisabled()

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.custom("Urbanist-Regular", size: 16))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 56)
                    .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
                    .cornerRadius(16)

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSearching = false
                            searchText = ""
                        }
                    } label: {
                        Text("Cancel")
                            .font(.custom("Urbanist-SemiBold", size: 14))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Status
            StatusView(selectedStatus: $selectedStatus)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)

            // List
            List {
                ForEach(filteredRehearsals, id: \.id) { rehearsal in
                    Button(action: {
                        selectedRehearsal = rehearsal
                    }) {
                        RehearsalItemView(rehearsal: rehearsal)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .id(rehearsal.id)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteRehearsal(rehearsal)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

            // Add Button
            NavigationLink(destination: AddRehearsalView()) {
                ButtonView(buttonText: "Add Rehearsal")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $selectedRehearsal) { rehearsal in
            RehearsalDetailView(rehearsal: rehearsal)
        }
        .sheet(isPresented: $showBandList) {
            BandListView()
        }
        .onAppear {
            // Perform background sync when view appears
            if let activeBand = activeBand {
                Task {
                    do {
                        try await BandSharingManager.shared.performFullSync(for: activeBand, context: modelContext)
                    } catch {
                        print("Background sync failed: \(error)")
                    }
                }
            }
        }
        }
    }

    private func deleteRehearsal(_ rehearsal: Rehearsal) {
        modelContext.delete(rehearsal)
    }
}

struct RehearsalItemView: View {
    @Environment(\.colorScheme) var colorScheme
    var rehearsal: Rehearsal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date
            HStack {
                Text(rehearsal.formattedDate)
                    .font(.custom("Urbanist-SemiBold", size: 18))
                    .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : .white)

                Spacer()
            }

            // Absent members
            if !(rehearsal.absentMembers ?? []).isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "person.slash")
                        .font(.custom("Urbanist-Regular", size: 12))
                        .foregroundColor(.orange)
                    Text((rehearsal.absentMembers ?? []).map { $0.name }.joined(separator: ", "))
                        .font(.custom("Urbanist-Regular", size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            // Song counts
            HStack(spacing: 16) {
                if (rehearsal.newSongs ?? []).count > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.custom("Urbanist-Regular", size: 12))
                        Text("\((rehearsal.newSongs ?? []).count) new")
                            .font(.custom("Urbanist-Regular", size: 14))
                    }
                    .foregroundColor(.green)
                }

                if (rehearsal.oldSongs ?? []).count > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note")
                            .font(.custom("Urbanist-Regular", size: 12))
                        Text("\((rehearsal.oldSongs ?? []).count) old")
                            .font(.custom("Urbanist-Regular", size: 14))
                    }
                    .foregroundColor(.secondary)
                }
            }

            // Notes preview
            if let notes = rehearsal.notes, !notes.isEmpty {
                Text(notes)
                    .font(.custom("Urbanist-Regular", size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color(red: 0.12, green: 0.13, blue: 0.16) : .white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Rehearsal.self, Song.self, BandMember.self, configurations: config)

    let context = container.mainContext
    let song1 = Song(title: "That's so true", artist: "Gracie Abrams", songDuration: 180000)
    let song2 = Song(title: "Rihanna", artist: "Kris Kross Amsterdam", songDuration: 200000)
    context.insert(song1)
    context.insert(song2)

    let member1 = BandMember(name: "Twan", instrument: "Guitar")
    context.insert(member1)

    let rehearsal1 = Rehearsal(
        date: Date().addingTimeInterval(7 * 24 * 60 * 60),
        absentMembers: [member1],
        notes: "Focus on harmonies",
        newSongs: [song1],
        oldSongs: [song2]
    )
    context.insert(rehearsal1)

    return RehearsalsView(selectedTab: .constant(1))
        .modelContainer(container)
}
