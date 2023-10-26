import SwiftUI

struct SetListHeader: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Voorste Venne")
                .font(Font.custom("Urbanist-SemiBold", size: 24))
            Spacer()
            Image("Search")
            Image("Group")  
        }
    }
}

#Preview {
    SetListHeader()
}
