import SwiftUI
import SwiftData

struct RehearsalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Bindable var rehearsal: Rehearsal

    @State private var showingAddNewSongs = false
    @State private var showingAddOldSongs = false
    @State private var showingEditAbsent = false
    @State private var showingEditNotes = false
    @State private var showingEditRecordingLink = false

    // Binding helpers for optional arrays
    private var newSongsBinding: Binding<[Song]> {
        Binding(
            get: { rehearsal.newSongs ?? [] },
            set: { rehearsal.newSongs = $0 }
        )
    }

    private var oldSongsBinding: Binding<[Song]> {
        Binding(
            get: { rehearsal.oldSongs ?? [] },
            set: { rehearsal.oldSongs = $0 }
        )
    }

    private var absentMembersBinding: Binding<[BandMember]> {
        Binding(
            get: { rehearsal.absentMembers ?? [] },
            set: { rehearsal.absentMembers = $0 }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                SetListHeader(title: rehearsal.formattedDate, showBackButton: true, showFilter: false)
                    .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Rehearsal info card
                    rehearsalInfoCard

                    // New Songs section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("New Songs")
                                .font(.custom("Urbanist-Bold", size: 22))
                                .foregroundColor(.primary)
                            Spacer()
                            Button(action: { showingAddNewSongs = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.custom("Urbanist-Regular", size: 24))
                                    .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
                            }
                        }

                        if (rehearsal.newSongs ?? []).isEmpty {
                            emptyStateView(message: "No new songs yet")
                        } else {
                            List {
                                ForEach(rehearsal.newSongs ?? []) { song in
                                    SongView(song: song)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                removeNewSong(song)
                                            } label: {
                                                Label("Delete", systemImage: "trash.fill")
                                            }
                                        }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .scrollDisabled(true)
                            .frame(height: CGFloat((rehearsal.newSongs ?? []).count) * 98)
                        }
                    }

                    // Old Songs section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Old Songs")
                                .font(.custom("Urbanist-Bold", size: 22))
                                .foregroundColor(.primary)
                            Spacer()
                            Button(action: { showingAddOldSongs = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.custom("Urbanist-Regular", size: 24))
                                    .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
                            }
                        }

                        if (rehearsal.oldSongs ?? []).isEmpty {
                            emptyStateView(message: "No old songs yet")
                        } else {
                            List {
                                ForEach(rehearsal.oldSongs ?? []) { song in
                                    SongView(song: song)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                removeOldSong(song)
                                            } label: {
                                                Label("Delete", systemImage: "trash.fill")
                                            }
                                        }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .scrollDisabled(true)
                            .frame(height: CGFloat((rehearsal.oldSongs ?? []).count) * 98)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingAddNewSongs) {
            AddSongToRehearsalView(songs: newSongsBinding, title: "Add New Songs")
        }
        .sheet(isPresented: $showingAddOldSongs) {
            AddSongToRehearsalView(songs: oldSongsBinding, title: "Add Old Songs")
        }
        .sheet(isPresented: $showingEditAbsent) {
            MemberPickerSheet(selectedMembers: absentMembersBinding)
        }
        .sheet(isPresented: $showingEditNotes) {
            EditNotesSheet(notes: Binding(
                get: { rehearsal.notes ?? "" },
                set: { rehearsal.notes = $0.isEmpty ? nil : $0 }
            ))
        }
        .sheet(isPresented: $showingEditRecordingLink) {
            EditRecordingLinkSheet(recordingLink: Binding(
                get: { rehearsal.recordingLink ?? "" },
                set: { rehearsal.recordingLink = $0.isEmpty ? nil : $0 }
            ))
        }
    }

    private var rehearsalInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Absent members
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "person.slash")
                    .font(.system(size: 18))
                    .foregroundColor(.orange)
                    .frame(width: 24, alignment: .center)
                Text((rehearsal.absentMembers ?? []).isEmpty ? "No absences" : (rehearsal.absentMembers ?? []).map { $0.name }.joined(separator: ", "))
                    .font(.custom("Urbanist-Medium", size: 15))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.8))
                    .lineLimit(2)
                Spacer()
                Button(action: { showingEditAbsent = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
                }
            }

            Divider()
                .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))

            // Notes
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "note.text")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
                    .frame(width: 24, alignment: .center)
                if let notes = rehearsal.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.custom("Urbanist-Medium", size: 15))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.8))
                        .lineLimit(2)
                } else {
                    Text("No notes")
                        .font(.custom("Urbanist-Medium", size: 15))
                        .foregroundColor(.secondary.opacity(0.6))
                        .italic()
                }
                Spacer()
                Button(action: { showingEditNotes = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
                }
            }

            Divider()
                .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1))

            // Recording Link
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.red)
                    .frame(width: 24, alignment: .center)
                if let recordingLink = rehearsal.recordingLink, !recordingLink.isEmpty {
                    if let url = URL(string: recordingLink) {
                        Link(destination: url) {
                            Text("Open Recording")
                                .font(.custom("Urbanist-Medium", size: 15))
                                .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
                                .underline()
                        }
                    } else {
                        Text("Invalid link")
                            .font(.custom("Urbanist-Medium", size: 15))
                            .foregroundColor(.red.opacity(0.6))
                            .italic()
                    }
                } else {
                    Text("No recording")
                        .font(.custom("Urbanist-Medium", size: 15))
                        .foregroundColor(.secondary.opacity(0.6))
                        .italic()
                }
                Spacer()
                Button(action: { showingEditRecordingLink = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color(red: 0.12, green: 0.13, blue: 0.16) : .white)
        .cornerRadius(16)
        .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.08), radius: 20, x: 0, y: 2)
    }

    private func emptyStateView(message: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                Image(systemName: "music.note")
                    .font(.system(size: 32))
                    .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96).opacity(0.3))
                Text(message)
                    .font(.custom("Urbanist-Medium", size: 14))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.vertical, 40)
            Spacer()
        }
        .background(colorScheme == .dark ? Color(red: 0.12, green: 0.13, blue: 0.16).opacity(0.3) : Color(red: 0.35, green: 0.3, blue: 0.96).opacity(0.03))
        .cornerRadius(12)
    }

    private func removeNewSong(_ song: Song) {
        if var songs = rehearsal.newSongs,
           let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs.remove(at: index)
            rehearsal.newSongs = songs
        }
    }

    private func removeOldSong(_ song: Song) {
        if var songs = rehearsal.oldSongs,
           let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs.remove(at: index)
            rehearsal.oldSongs = songs
        }
    }
}

// Sheet for adding songs to rehearsal
struct AddSongToRehearsalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    @Binding var songs: [Song]
    let title: String

    @Query private var allSongs: [Song]
    @State private var selectedSongs: Set<Song> = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text(title)
                        .font(.custom("Urbanist-SemiBold", size: 24))
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.custom("Urbanist-SemiBold", size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Song list
                List {
                    ForEach(allSongs) { song in
                        Button(action: {
                            if selectedSongs.contains(song) {
                                selectedSongs.remove(song)
                            } else {
                                selectedSongs.insert(song)
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(song.title)
                                        .font(.custom("Urbanist-SemiBold", size: 16))
                                        .foregroundColor(.primary)
                                    Text(song.artist)
                                        .font(.custom("Urbanist-Regular", size: 14))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if selectedSongs.contains(song) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.custom("Urbanist-Regular", size: 22))
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)

                // Add button
                Button(action: addSelectedSongs) {
                    ButtonView(buttonText: "Add \(selectedSongs.count) Song\(selectedSongs.count == 1 ? "" : "s")")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .disabled(selectedSongs.isEmpty)
                .opacity(selectedSongs.isEmpty ? 0.5 : 1.0)
            }
        }
    }

    private func addSelectedSongs() {
        for song in selectedSongs {
            if !songs.contains(where: { $0.id == song.id }) {
                songs.append(song)
            }
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// Sheet for editing notes
struct EditNotesSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Binding var notes: String
    @State private var editedNotes: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Edit Notes")
                        .font(.custom("Urbanist-SemiBold", size: 24))
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.custom("Urbanist-SemiBold", size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Spacer()

                // Notes input
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .topLeading) {
                        if editedNotes.isEmpty {
                            Text("Add notes about this rehearsal...")
                                .font(.custom("Urbanist-SemiBold", size: 14))
                                .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.4) : Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.6))

                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }

                        TextEditor(text: $editedNotes)
                            .font(.custom("Urbanist-SemiBold", size: 14))
                            .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
                            
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .frame(height: 150)
                            .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
                            .cornerRadius(16)
                            .scrollContentBackground(.hidden)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                // Save button
                Button(action: saveNotes) {
                    ButtonView(buttonText: "Save")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            editedNotes = notes
        }
    }

    private func saveNotes() {
        notes = editedNotes
        presentationMode.wrappedValue.dismiss()
    }
}

// Sheet for editing recording link
struct EditRecordingLinkSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Binding var recordingLink: String
    @State private var editedLink: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Recording Link")
                        .font(.custom("Urbanist-SemiBold", size: 24))
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.custom("Urbanist-SemiBold", size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Spacer()

                // Link input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Paste link to cloud storage (Google Drive, Dropbox, iCloud, etc.)")
                        .font(.custom("Urbanist-Regular", size: 12))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    TextField("", text: $editedLink)
                        .font(.custom("Urbanist-SemiBold", size: 14))
                        .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
                        .padding(.horizontal, 16)
                        .frame(height: 56)
                        .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
                        .cornerRadius(16)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .overlay(
                            Group {
                                if editedLink.isEmpty {
                                    HStack {
                                        Text("https://drive.google.com/...")
                                            .font(.custom("Urbanist-SemiBold", size: 14))
                                            .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.4) : Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.6))
                                            .padding(.leading, 16)
                                        Spacer()
                                    }
                                    .allowsHitTesting(false)
                                }
                            }
                        )
                }
                .padding(.horizontal, 16)

                Spacer()

                // Save button
                Button(action: saveLink) {
                    ButtonView(buttonText: "Save")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            editedLink = recordingLink
        }
    }

    private func saveLink() {
        recordingLink = editedLink.trimmingCharacters(in: .whitespaces)
        presentationMode.wrappedValue.dismiss()
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

    let rehearsal = Rehearsal(
        date: Date().addingTimeInterval(7 * 24 * 60 * 60),
        absentMembers: [member1],
        notes: "Focus on harmonies",
        newSongs: [song1],
        oldSongs: [song2]
    )
    context.insert(rehearsal)

    return RehearsalDetailView(rehearsal: rehearsal)
        .modelContainer(container)
}
