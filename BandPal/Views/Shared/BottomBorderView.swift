import SwiftUI

struct BottomBorderView: View {
    // Example item names, adjust as needed
    private let items = ["Home", "Profile", "Settings"]

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 20) {
                ForEach(items, id: \.self) { item in
                    Button(action: {
                        // Handle item click here
                        print("\(item) clicked")
                    }) {
                        ItemView(name: item)
                    }
                }
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, minHeight: 48)
            .padding(.top, 8)
        }
        .frame(width: 428)
        .cornerRadius(24)
    }
}

struct ItemView: View {
    let name: String

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Image(name) // Use your image names
                .frame(width: 19, height: 20)
                .padding(.horizontal, 2.5)
                .padding(.vertical, 2)
                .frame(width: 24, height: 24)
            Text(name)
                .font(Font.custom("Urbanist", size: 10).weight(.medium))
                .kerning(0.2)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.62, green: 0.62, blue: 0.62))
                .frame(maxWidth: .infinity)
        }
    }
}

struct BottomBorderView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBorderView()
    }
}
