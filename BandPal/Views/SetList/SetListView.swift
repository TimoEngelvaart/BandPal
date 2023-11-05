import SwiftUI

struct SetListView: View {
    @State var setListItems: [SetListItem] = []
    
    var totalDurationInSeconds: Int {
            setListItems.compactMap { $0.songDuration }.reduce(0, +) / 1000
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
        NavigationStack {
            VStack {
                // Header
                SetListHeader(title: "Voorste Venne", showBackButton: false)
                    .padding(.bottom, 24)
                
                //Title
                SetListHeaderTextView(numSongs: setListItems.count, totalDuration: totalDurationInSeconds)
                    .padding(.bottom, 24)
                
                //ListItems
                List(setListItems){ song in
                    SetListItemView(item: SetListItem(title: song.title, artist: song.artist, albumArt: song.albumArt, songDuration: song.songDuration))
                        .listRowSeparator(.hidden) // Hide the separator
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = setListItems.firstIndex(where: { $0.id == song.id }) {
                                    setListItems.remove(at: index)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }

                .listStyle(PlainListStyle())
                
                NavigationLink(destination: AddSongView(setListItems: $setListItems)) {
                    ButtonView()
                }
                
                BottomBorderView()
                
            }
        }
    }
}

#Preview {
    SetListView(setListItems: [SetListItem(title: "test", artist: "test", albumArt: "Test", songDuration: 0)])
}
