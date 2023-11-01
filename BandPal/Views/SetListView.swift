import SwiftUI

struct SetListView: View {
    @State var setListItems: [SetListItem] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header
                SetListHeader(showBackButton: false)
                    .padding(.bottom, 24)
                
                //Title
                SetListHeaderTextView()
                    .padding(.bottom, 24)
                
                //ListItems
                ScrollView {
                    ForEach(setListItems) { song in
                           SetListItemView(item: SetListItem(title: song.title, artist: song.artist, albumArt: song.albumArt, songDuration: song.songDuration))
                       }
//                    SetListItemView(item: SetListItem(title: "Levels", artist: "Avicii", albumArt: "test", songDuration: 0))
                    NavigationLink(destination: AddSongView(setListItems: $setListItems)) {
                        ButtonView()
                    }
                    
                    
                }
                
                BottomBorderView()
                
            }
        }
    }
}

#Preview {
    SetListView()
}
