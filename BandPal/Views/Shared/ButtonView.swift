import SwiftUI

struct ButtonView: View {
var buttonText: String
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // body / large / bold
            Text(self.buttonText)
              .font(
                Font.custom("Urbanist", size: 16)
                  .weight(.bold)
              )
              .kerning(0.2)
              .multilineTextAlignment(.center)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity, minHeight: 22, maxHeight: 22, alignment: .center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, minHeight: 58, maxHeight: 58, alignment: .center)
        .background(Color(red: 0.35, green: 0.3, blue: 0.96))
        .cornerRadius(100)
        .shadow(color: Color(red: 0.35, green: 0.3, blue: 0.96).opacity(0.25), radius: 12, x: 4, y: 8)

    }
    
}

#Preview {
    ButtonView(buttonText: "Test")
}
