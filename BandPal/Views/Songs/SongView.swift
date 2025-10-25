import SwiftUI

struct SongView: View {
    let song: Song
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            albumArtView
            songDetailsView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 12)
        .padding(.vertical, 10)
        .background(colorScheme == .dark ? Color(red: 0.12, green: 0.13, blue: 0.16) : .white)
        .cornerRadius(16)
        .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.05), radius: 20, x: 0, y: 2)

    }

    private var albumArtView: some View {
        ZStack {
            if let albumArt = song.albumArt, let url = URL(string: albumArt) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 70)
                            .clipped()
                            .cornerRadius(12)
                    case .empty:
                        ProgressView()
                            .frame(width: 70, height: 70)
                    default:
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 70, height: 70)
                    }
                }
            } else {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 70, height: 70)
            }
        }
    }

    private var songDetailsView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(song.title)
                .font(Font.custom("Urbanist-SemiBold", size: 16))
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : .white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            Text(song.artist)
                .font(Font.custom("Urbanist-Regular", size: 13))
                .fontWeight(.semibold)
                .kerning(0.2)
                .foregroundColor(Color(red: 0.35, green: 0.3, blue: 0.96))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            HStack(spacing: 4) {
                Image("Time Circle")
                    .frame(width: 12, height: 12)

                Text(song.formattedDuration)
                    .font(Font.custom("Urbanist-Light", size: 12))
                    .kerning(0.2)
                    .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    SongView(song: Song(title: "Levels", artist: "Avicii", albumArt: "test", songDuration: 500))
}
