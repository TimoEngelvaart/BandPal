import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SongsView: View {
    @Bindable var setlist: Setlist
    @Environment(\.presentationMode) var presentationMode
    @State private var draggingItem: Song?

    var totalDurationInSeconds: Int {
        (setlist.songs ?? []).compactMap { $0.songDuration }.reduce(0, +) / 1000
    }

    var formattedTotalDuration: String {
        let totalSeconds = totalDurationInSeconds
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    var body: some View {
        VStack {
            // Header
            SetListHeader(title: "Voorste Venne", showBackButton: true, showFilter: false)
                .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .leading)
                .padding(.bottom, 24)

            // Title
            SetListHeaderTextView(numSongs: setlist.songs?.count ?? 0, totalDuration: totalDurationInSeconds)
                .padding(.bottom, 24)

            // ListItems
            List {
                ForEach(setlist.songs ?? []) { song in
                    SongRow(song: song)
                        .onDrag {
                            self.draggingItem = song
                            return NSItemProvider(object: String(song.id.uuidString) as NSString)
                        }
                        .onDrop(of: [UTType.text], delegate: SongDropDelegate(item: song, songs: $setlist.songs, draggingItem: $draggingItem))
                }
                .onMove(perform: move)
            }
            .listStyle(PlainListStyle())
            .padding(.horizontal, 16 - 16)

            NavigationLink(destination: AddSongView(songs: $setlist.songs)) {
                ButtonView(buttonText: "Add Song")
            }
        }
        .padding(.horizontal, 16)
        .navigationBarBackButtonHidden(true)
    }

    func move(from source: IndexSet, to destination: Int) {
        if var songs = setlist.songs {
            songs.move(fromOffsets: source, toOffset: destination)
            setlist.songs = songs
        }
    }
}

struct SongRow: View {
    let song: Song

    var body: some View {
        ZStack {
            SongView(song: song)
                .listRowSeparator(.hidden) // Hide the separator
                .padding(.top, 16)
        }
        .listRowInsets(EdgeInsets()) // Remove default padding to extend swipe area
    }
}

struct SongDropDelegate: DropDelegate {
    let item: Song
    @Binding var songs: [Song]?
    @Binding var draggingItem: Song?

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem, var songArray = songs else { return }

        if draggingItem != item {
            guard let fromIndex = songArray.firstIndex(of: draggingItem),
                  let toIndex = songArray.firstIndex(of: item) else { return }

            withAnimation {
                songArray.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                songs = songArray
            }
        }
    }
}

#Preview {
    let setlist = Setlist(title: "Test Setlist", date: Date(), songs: [
        Song(title: "test", artist: "test", albumArt: "Test", songDuration: 500000),
        Song(title: "test 2", artist: "test", albumArt: "Test", songDuration: 500000)
    ])
    return SongsView(setlist: setlist)
        .modelContainer(for: [Setlist.self, Song.self], inMemory: true)
}
