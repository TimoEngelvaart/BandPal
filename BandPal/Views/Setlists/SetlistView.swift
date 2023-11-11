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
                        ZStack {
                            // Your custom list item view
                            SetlistItemView(setlistItem: setlist)

                            // Invisible NavigationLink
                            NavigationLink(destination: SongsView(songs: setlist.setlist)) {
                                EmptyView()
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 0)
                            .opacity(0)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                    ButtonView()
                }
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



