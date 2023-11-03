import SwiftUI

struct SetListHeaderTextView: View {
    var numSongs: Int
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("\(numSongs) " + (numSongs > 1 ? "Songs" : "Song"))
                .font(
                Font.custom("Urbanist", size: 20)
                .weight(.bold)
                )
            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))

            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
