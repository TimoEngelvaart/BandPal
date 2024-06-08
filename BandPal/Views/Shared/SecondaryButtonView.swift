import SwiftUI

struct SecondaryButtonView: View {
    var placeholder: String
    var onCommit: () -> Void

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        Button(action: onCommit) {
            Text("Website")
            .font(
            Font.custom("Urbanist", size: 18)
            .weight(.bold)
            )
            .kerning(0.2)
            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
        }
        
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.white)
        .cornerRadius(20)
        .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.05), radius: 30, x: 0, y: 4)
    }
  
}


struct SecondaryButtonViewPreviewContainer: View {
    var body: some View {
        SecondaryButtonView(placeholder: "Test", onCommit: {
            print("Button tapped")
        })
    }
}

#Preview {
    SecondaryButtonViewPreviewContainer()
}
