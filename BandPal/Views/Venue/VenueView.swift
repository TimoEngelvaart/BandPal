import SwiftUI

struct VenueView: View {
    @State var venues: [Venue] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 24) {
                VStack(alignment: .center, spacing: 24) {
                    SetListHeader(title: "Venues", showBackButton: false, showFilter: false)
                        .padding(.bottom, 24)
                    HStack(alignment: .top, spacing: 0) {
                        StatusView()
                            .padding(0)
                    }
                    List(venues) { venue in
                                        NavigationLink(destination: SetListView(setListItems: venue.setList)) {
                                            VenueItem(venueItem: venue) // Assuming VenueItem takes a Venue object directly
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

#Preview {
    VenueView(venues: [Venue(title: "Voorste Venne", date: Date(), setList: [SetListItem(title: "Song 1", artist: "Artist 1", albumArt: nil, songDuration: 300)])])
}
