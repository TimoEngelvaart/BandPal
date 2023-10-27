import SwiftUI

struct SetListHeader: View {
    var body: some View {
        HStack {
            Text("Voorste Venne")
                .font(Font.custom("Urbanist-SemiBold", size: 24))
            Spacer()
            Image("Search")
            Image("Group")
                .padding(.leading, 3.5)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    SetListHeader()
}
