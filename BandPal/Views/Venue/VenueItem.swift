import SwiftUI

extension Date {
    func customFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: self)
    }
}

struct VenueItem: View {
    var venueItem: Venue
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(venueItem.title)
                .bold()
                .font(.custom("Urbanist-Regular", size: 18))
                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                Spacer()
            
            Text(venueItem.date.customFormatted())
                .bold()
                .font(.custom("Urbanist", size: 16))
                .kerning(0.2)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
        }
        .padding() // Adjust padding as needed
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.05), radius: 30, x: 0, y: 4)
        )
    }
}
 
#Preview{
    VenueView(venues: [Venue(title: "Voorste Venne", date: Date(), setList: [SetListItem(title: "Song 1", artist: "Artist 1", albumArt: nil, songDuration: 300)])])
}
