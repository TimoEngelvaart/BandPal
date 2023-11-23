import SwiftUI

struct SongView: View {
    let song: Song
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    var body: some View {
        HStack {
            albumArtView
            songDetailsView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 18)
        .padding(.vertical, 14)
        .background(colorScheme == .dark ? Color(red: 0.12, green: 0.13, blue: 0.16) : .white)
        .cornerRadius(28)
        .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.05), radius: 30, x: 0, y: 4)

    }

    private var albumArtView: some View {
        ZStack {
            if let albumArt = song.albumArt, let url = URL(string: albumArt) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipped()
                            .cornerRadius(20)
                    case .empty:
                        ProgressView()
                            .frame(width: 120, height: 120)
                    default:
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 120, height: 120)
                    }
                }
            } else {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 120, height: 120)
            }
        }
    }

    private var songDetailsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(song.title)
                .font(Font.custom("Urbanist-SemiBold", size: 20))
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : .white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(song.artist)
                .font(Font.custom("Urbanist-Regular", size: 14))
                .fontWeight(.semibold)
                .kerning(0.2)
                .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Image("Time Circle")
                    .frame(width: 15.33, height: 15.33)

                Text(song.formattedDuration)
                    .font(Font.custom("Urbanist-Light", size: 14))
                    .kerning(0.2)
                    .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SongView(song: Song(title: "Levels", artist: "Avicii", albumArt: "test", songDuration: 500))
}
