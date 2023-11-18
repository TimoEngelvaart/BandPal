import SwiftUI

struct SongView: View {
    let song: Song
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                   if let albumArt = song.albumArt, let url = URL(string: albumArt) {
                       AsyncImage(url: url) { phase in
                           switch phase {
                           case .success(let image):
                               image
                                   .resizable()
                                   .aspectRatio(contentMode: .fill)
                                   .frame(width: 120, height: 120)
                                   .clipped()
                                   .cornerRadius(20)
                           case .empty:
                               ProgressView() // Shows a spinner while loading
                                   .frame(width: 120, height: 120)
                           default:
                               Rectangle()
                                   .foregroundColor(.clear)
                                   .frame(width: 120, height: 120)
                           }
                       }
                   } else {
                       // Display a placeholder or empty rectangle
                       Rectangle()
                           .foregroundColor(.clear)
                           .frame(width: 120, height: 120)
                   }
               }
                VStack(alignment: .leading, spacing: 10) {
                    Text(song.title)
                    .font(
                    Font.custom("Urbanist-SemiBold", size: 20)
                    .weight(.bold)
                    )
                    .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))

                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    Text(song.artist)
                        .font(
                        Font.custom("Urbanist-Regular", size: 14)
                        .weight(.semibold)
                        )
                        .kerning(0.2)
                        .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))

                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    //clock + duration
                    HStack(alignment: .center, spacing: 8) {
                        HStack(alignment: .center, spacing: 8) {
                            Image("Time Circle")
                            .frame(width: 15.33, height: 15.33)
                            // body / medium / regular
                            Text(song.formattedDuration)
                                  .font(Font.custom("Urbanist-Light", size: 14))
                                  .kerning(0.2)
                                  .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                                  .frame(maxWidth: .infinity, alignment: .topLeading)
                              .font(Font.custom("Urbanist-Light", size: 14))
                              .kerning(0.2)
                              .foregroundColor(Color(red: 0.38, green: 0.38, blue: 0.38))
                              .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .padding(0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(0)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        .padding(.horizontal, 16)
    }
    
}

#Preview {
    SongView(song: Song(title: "Levels", artist: "Avicii", albumArt: "test", songDuration: 500))
}
