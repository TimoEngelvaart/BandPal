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
        VStack(alignment: .center, spacing: 24) {
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
            .padding(24)
            .background(.white)
            .cornerRadius(20)
            .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.05), radius: 30, x: 0, y: 4)
        }
        .frame(width: 380)
    }
}
 
#Preview{
    VenueItem(venueItem: Venue(title: "test", date: Date()))
}
