import SwiftUI

struct SetListHeader: View {
    var title: String
    var showBackButton: Bool = true
    var showSearchButton: Bool = true
    var showFilter: Bool = true
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        HStack {
            if showBackButton {
            Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image("Arrow-left")
                        }
            }
            Text(self.title)
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
    }
}

#Preview {
    SetListHeader(title: "Voorste Venne")
}
