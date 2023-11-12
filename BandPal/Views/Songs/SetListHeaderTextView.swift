import SwiftUI

struct SetListHeaderTextView: View {
    var numSongs: Int
    var totalDuration: Int
    
    var formattedTotalDuration: String {
            let hours = totalDuration / 3600
            let minutes = (totalDuration % 3600) / 60
            let seconds = totalDuration % 60
            if hours > 0 {
                return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
        }
    
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            //Header
            Text("\(numSongs) " + (numSongs == 1 ? "Song" : "Songs"))
                .font(Font.custom("Urbanist-Regular", size: 20)
                .weight(.bold))
            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
            .frame(maxWidth: .infinity, alignment: .topLeading)
            //Icon
            Image("Time Circle 16")
                .frame(width: 23, height: 23)
            //Time
            Text(self.formattedTotalDuration)
                .font(Font.custom("Urbanist-Regular", size: 16))
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SetListHeaderTextView(numSongs: 2, totalDuration: 8484848)
}
