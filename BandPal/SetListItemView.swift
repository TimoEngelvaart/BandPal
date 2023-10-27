import SwiftUI

struct SetListItemView: View {
    let item: SetListItem
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 120, height: 120)
                    .background(
                        Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipped()
                    )
                    .cornerRadius(20)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text(item.title)
                    .font(
                    Font.custom("Urbanist-SemiBold", size: 20)
                    .weight(.bold)
                    )
                    .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))

                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    Text(item.artist)
                    .font(
                    Font.custom("Urbanist-Regular", size: 14)
                    .weight(.semibold)
                    )
                    .kerning(0.2)
                    .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))

                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .padding(0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .frame(width: 120, height: 120)
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .leading)

        }
       
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 14)
        .padding(.trailing, 18)
        .padding(.vertical, 14)
        .background(.white)
        .cornerRadius(28)
        .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.05), radius: 30, x: 0, y: 4)
        .padding(.horizontal, 24)
    }
    
}

#Preview {
    SetListItemView(item: SetListItem(title: "Levels", artist: "Avicii", imageName: "Levels"))
}
