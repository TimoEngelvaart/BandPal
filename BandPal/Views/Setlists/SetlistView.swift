import SwiftUI

struct SetlistView: View {
    @State var setlists: [Setlist] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 24) {
                VStack(alignment: .center, spacing: 24) {
                    SetListHeader(title: "Setlists", showBackButton: false, showFilter: false)
                    StatusView()
                    List(setlists) { setlist in
                        NavigationLink(destination: SongsView(songs: setlist.setlist)) {
                            SetlistItemView(setlistItem: setlist)
                        }
                        .buttonStyle(PlainButtonStyle()) // Removes the arrow
                        .listRowSeparator(.hidden) // Hide the separator
                    }
                    ButtonView()
                }
                .listStyle(PlainListStyle()) // Removes additional styling from List
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        BottomBorderView()
    }
}

#Preview {
    SetlistView(setlists: [Setlist(title: "Voorste Venne", date: Date(), setlist: [Song(title: "Heaven", artist: "Avicii", albumArt: nil, songDuration: nil)])])
}



