import SwiftUI

struct VenueView: View {
    @State var Venues: [Venue] = []
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(alignment: .center, spacing: 24) {
                SetListHeader(title: "test", showBackButton: false, showFilter: false)
                    .padding(.bottom, 24)
                    HStack(alignment: .top, spacing: 0) {
                        StatusView()
                            .padding(0)
                    }
                List (Venues) { venue in
                    VenueItem(venueItem: Venue(title: "Test", date: Date()))
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
    VenueView()
}
