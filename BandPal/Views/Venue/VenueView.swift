import SwiftUI

struct VenueView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 28) {
            Text("Test")
                .font(Font.custom("Urbanist-Regular", size: 24))
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 48)
        .frame(width: 428, height: 882, alignment: .top)
    }
}

#Preview {
    VenueView()
}
