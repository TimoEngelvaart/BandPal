import SwiftUI

struct BottomBorderView: View {
    @Binding var selectedTab: Int
    private let items = ["Setlist", "Rehearsals"]

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 20) {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    Button(action: {
                        selectedTab = index
                    }) {
                        ItemView(name: item, isSelected: selectedTab == index)
                    }
                }
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, minHeight: 48)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(24)
    }
}

struct ItemView: View {
    let name: String
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Image(name == "Setlist" ? "Setlist" : "Home")
                .renderingMode(.template)
                .frame(width: 19, height: 20)
                .padding(.horizontal, 2.5)
                .padding(.vertical, 2)
                .frame(width: 24, height: 24)
                .foregroundColor(isSelected ? .primary : Color(red: 0.62, green: 0.62, blue: 0.62))
            Text(name)
                .font(Font.custom("Urbanist", size: 10).weight(.medium))
                .kerning(0.2)
                .multilineTextAlignment(.center)
                .foregroundColor(isSelected ? .primary : Color(red: 0.62, green: 0.62, blue: 0.62))
                .frame(maxWidth: .infinity)
        }
    }
}

struct BottomBorderView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBorderView(selectedTab: .constant(0))
    }
}
