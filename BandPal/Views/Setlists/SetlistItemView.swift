import SwiftUI

extension Date {
    func customFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: self)
    }
}

struct SetlistItemView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme // To detect dark or light mode
    
    var setlistItem: Setlist
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(setlistItem.title)
                .bold()
                .font(.custom("Urbanist-Regular", size: 18))
                .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : .white)
                Spacer()
            
            Text(setlistItem.date.customFormatted())
                .bold()
                .font(.custom("Urbanist", size: 16))
                .kerning(0.2)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colorScheme == .dark ? Color(red: 0.12, green: 0.13, blue: 0.16) : .white)

        .cornerRadius(20)
        .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.05), radius: 30, x: 0, y: 4)
        
    }
}
 
#Preview{
    SetlistItemView(setlistItem: Setlist(title: "Voorste Venne", date: Date(), setlist: [Song(title: "Song 1", artist: "Artist 1", albumArt: nil, songDuration: 300)]))
}
