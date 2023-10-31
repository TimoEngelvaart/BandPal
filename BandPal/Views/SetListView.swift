import SwiftUI

struct SetListView: View {
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
                    SetListItemView(item: SetListItem(title: "Levels", artist: "Avicii", albumArt: "test", songDuration: 0))
                    NavigationLink(destination: AddSongView()) {
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
