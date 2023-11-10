import SwiftUI

struct StatusView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            StatusColumn(title: "Upcoming", color: Color(red: 0.62, green: 0.62, blue: 0.62))
            StatusColumn(title: "Completed", color: Color(red: 0.62, green: 0.62, blue: 0.62))
            StatusColumn(title: "Cancelled", color: Color(red: 0.35, green: 0.3, blue: 0.96), lineThickness: 4)
        }
    }
}

struct StatusColumn: View {
    let title: String
    let color: Color
    var lineThickness: CGFloat = 2 // Default line thickness
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(Font.custom("Urbanist", size: 18).weight(.semibold))
                .kerning(0.2)
                .multilineTextAlignment(.center)
                .foregroundColor(color)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity, minHeight: lineThickness, maxHeight: lineThickness)
                .background(color)
                .cornerRadius(100)
        }
        .padding(.vertical, 1)
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
}

// Preview
#Preview {
    StatusView()
}
