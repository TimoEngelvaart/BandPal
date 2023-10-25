import SwiftUI

struct SetListView: View {
    var body: some View {
        VStack {
            // H4/bold
            Text("Voorste Venne")
                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

#Preview {
    SetListView()
}
