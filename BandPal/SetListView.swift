import SwiftUI

struct SetListView: View {
    var body: some View {
        VStack {
            // Header
            SetListHeader()
                .padding(.bottom, 24)
            
            //Title
            SetListHeaderTextView()
                .padding(.bottom, 24)
            
            //ListItems
            ScrollView {
                SetListItemView(item: SetListItem(title: "Levels", artist: "Avicii", imageName: "Levels"))
                SetListItemView(item: SetListItem(title: "Levels", artist: "Avicii", imageName: "Levels"))
                SetListItemView(item: SetListItem(title: "Levels", artist: "Avicii", imageName: "Levels"))
                SetListItemView(item: SetListItem(title: "Levels", artist: "Avicii", imageName: "Levels"))
                SetListItemView(item: SetListItem(title: "Levels", artist: "Avicii", imageName: "Levels"))
                SetListItemView(item: SetListItem(title: "Levels", artist: "Avicii", imageName: "Levels"))
                SetListItemView(item: SetListItem(title: "Levels", artist: "Avicii", imageName: "Levels"))
                SetListItemView(item: SetListItem(title: "Levels", artist: "Avicii", imageName: "Levels"))
            }
            
            BottomBorderView()
        }
    }
}

#Preview {
    SetListView()
}
