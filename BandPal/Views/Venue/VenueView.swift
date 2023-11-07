import SwiftUI

struct VenueView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(alignment: .center, spacing: 24) {
                SetListHeader(title: "test", showBackButton: false, showFilter: false)
                    .padding(.bottom, 24)
                    HStack(alignment: .top, spacing: 0) {
                        StatusView()
                            .padding(0)
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
