import SwiftUI

struct InputView: View {
    @State private var inputText: String = ""
    var placeholder: String
    @Binding var text: String
    var onCommit: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            TextField(placeholder, text: $text, onCommit: onCommit)
                .font(Font.custom("Urbanist", size: 14).weight(.semibold))
                .kerning(0.2)
                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                .padding(.horizontal, 20)
                .frame(height: 56)
                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                .cornerRadius(16)
        }
        .padding(.horizontal, 24)
    }
}
