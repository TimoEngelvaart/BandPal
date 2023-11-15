import SwiftUI

struct StatusView: View {
    @State private var selectedStatus: String = "Upcoming"
    let statuses = ["Upcoming", "Completed", "Cancelled"]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(statuses, id: \.self) { status in
                Button(action: {
                    self.selectedStatus = status
                }) {
                    VStack(alignment: .center, spacing: 12) {
                        Text(status)
                            .font(Font.custom("Urbanist-SemiBold", size: 18))
                            .kerning(0.2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(self.selectedStatus == status ? Color(red: 0.35, green: 0.3, blue: 0.96) : Color(red: 0.62, green: 0.62, blue: 0.62))
                            .frame(maxWidth: .infinity, alignment: .center)

                        if selectedStatus == status {
                            Rectangle()
                                .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
                                .frame(height: 4)
                                .cornerRadius(2)
                        } else {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct StatusColumn: View {
    let title: String
    let color: Color
    var lineThickness: CGFloat = 1 // Default line thickness
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(Font.custom("Urbanist-SemiBold", size: 18))
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
