import SwiftUI

struct SetListHeader: View {
    var showBackButton: Bool = true
    var showSearchButton: Bool = true
    var showFilter: Bool = true
    
    var body: some View {
        HStack {
            if showBackButton {
                Image("Arrow-left")
            }
            Text("Voorste Venne")
                .font(Font.custom("Urbanist-SemiBold", size: 24))
            Spacer()
            if showSearchButton {
                Image("Search")
            }
            if showFilter {
                Image("Group")
                    .padding(.leading, 3.5)
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    SetListHeader()
}
