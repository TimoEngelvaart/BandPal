import SwiftUI

struct AddSongView: View {
    var body: some View {
        VStack {
            SetListHeader(showSearchButton: false, showFilter: false)
                .padding(.bottom, 24)
            // Header
            Text("Song Information")
            .font(Font.custom("Urbanist-Light", size: 16))
                .kerning(0.2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
            // Input field
            HStack(alignment: .center, spacing: 12) {
                Text("Levels")
                  .font(
                    Font.custom("Urbanist", size: 14)
                      .weight(.semibold)
                  )
                  .kerning(0.2)
                  .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                  .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 0)
            .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56, alignment: .leading)
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .padding(.horizontal, 24)
            .padding(.bottom, 14)
            .cornerRadius(16)
            
            HStack(alignment: .center, spacing: 12) {
                Text("Levels")
                  .font(
                    Font.custom("Urbanist", size: 14)
                      .weight(.semibold)
                  )
                  .kerning(0.2)
                  .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                  .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 0)
            .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56, alignment: .leading)
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .cornerRadius(16)
        }
    }
}


#Preview {
    AddSongView()
}
