import SwiftUI

struct SetlistView: View {
    @State var setlists: [Setlist] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 24) {
                VStack(alignment: .center, spacing: 24) {
                    SetListHeader(title: "Setlists", showBackButton: false, showFilter: false)
                        .padding(.bottom, 24)
                    HStack(alignment: .top, spacing: 0) {
                        StatusView()
                            .padding(0)
                    }
                    List(setlists) { setlist in
                        NavigationLink(destination: SongView(setListItems: Setlist(title: setlist.title, date: setlist.date, setlist: setlist.setlist))) {
                                        }
                                        .listRowInsets(EdgeInsets()) // This removes the default padding
                                        .frame(maxWidth: .infinity, alignment: .leading) // Extends the row content to full width
                                        .listRowSeparator(.hidden) // Hides the row separators
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
}

