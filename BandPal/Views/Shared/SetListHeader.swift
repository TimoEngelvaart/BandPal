import SwiftUI

struct SetListHeader: View {
    var title: String
    var showTitle: Bool = true
    var showBackButton: Bool = true
    var showSearchButton: Bool = true
    var showFilter: Bool = true
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme: ColorScheme // To detect dark or light mode
    
    var body: some View {
        HStack {
            if showBackButton {
            Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            colorScheme == .light ? Image("Arrow-left") : Image("Arrow-left-white")
                        }
            }
            if showTitle {
                Text(self.title)
                    .font(Font.custom("Urbanist-SemiBold", size: 24))
            }
            Spacer()
            if showSearchButton {
                Image(colorScheme == .light ? "Search" : "Search-white")
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
