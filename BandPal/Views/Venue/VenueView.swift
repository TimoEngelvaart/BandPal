import SwiftUI

struct VenueView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 28) {
            VStack(alignment: .center, spacing: 24) {
    
                SetListHeader(title: "test", showBackButton: false, showFilter: false)
                    .padding(.bottom, 24)
                HStack(alignment: .top, spacing: 0) {
                    StatusView()
                }
                Spacer()
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .top)
            
            
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 48)
        BottomBorderView()
    }
    
}

#Preview {
    VenueView()
}
