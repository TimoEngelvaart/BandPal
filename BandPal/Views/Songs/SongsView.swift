import SwiftUI

struct SongsView: View {
    @State var songs: [Song] = []
    @Environment(\.presentationMode) var presentationMode
    
    var totalDurationInSeconds: Int {
            songs.compactMap { $0.songDuration }.reduce(0, +) / 1000
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
                    
                    
                
                
                //Title
                SetListHeaderTextView(numSongs: songs.count, totalDuration: totalDurationInSeconds)
                    .padding(.bottom, 24)
                
                //ListItems
                List(songs){ song in
                    ZStack {
                        SongView(song: Song(title: song.title, artist: song.artist, albumArt: song.albumArt, songDuration: song.songDuration))
                            .listRowSeparator(.hidden) // Hide the separator
                            .swipeActions {
                                Button(role: .destructive) {
                                    if let index = songs.firstIndex(where: { $0.id == song.id }) {
                                        songs.remove(at: index)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                        }
                    }
                    .listRowInsets(EdgeInsets()) // Remove default padding to extend swipe area
                }
      

                .listStyle(PlainListStyle())
                .padding(.horizontal, 16 - 16)
                
                NavigationLink(destination: AddSongView(songs: $songs)) {
                    ButtonView(buttonText: "Add Song")
                }
                BottomBorderView()
                
   
                
            }
            // Apply padding only if the view is presented in a standalone mode
             .padding(.horizontal, 16)
            .navigationBarBackButtonHidden(true)
        }
}

#Preview {
    SongsView(songs: [Song(title: "test", artist: "test", albumArt: "Test", songDuration: 0)])
}
