import SwiftUI

struct AddSongView: View {
    @State private var searchQuery: String = ""
    @State private var searchResults: [Song] = []
    @Binding var songs: [Song]
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    func onSearchQueryChange() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        searchMusic(query: searchQuery)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SetListHeader(title: "Add Song", showSearchButton: false, showFilter: false)
                .padding(.bottom, 24)
                .padding(.horizontal, 16)
            
            // Search Bar
            TextField("Search for a song", text: $searchQuery)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .onChange(of: searchQuery) { _ in
                    onSearchQueryChange()
                }
            
            // Search Results
            if !searchResults.isEmpty {
                List(searchResults, id: \.id) { song in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(song.title)
                            Text(song.artist).font(.subheadline).foregroundColor(.gray)
                        }
                        Spacer()
                        if let albumArt = song.albumArt, let url = URL(string: albumArt) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                case .failure:
                                    Text("Failed to load")
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "music.note")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        songs.append(song)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            } else {
                Text("No results found")
                    .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func searchMusic(query: String) 
}

struct CoverArtData: Codable {
    var images: [CoverArtImage]
}

struct CoverArtImage: Codable {
    var image: String
}

struct MusicBrainzSearchResults: Codable {
    var recordings: [Recording]
}

struct Recording: Codable {
    var title: String?
    var length: Int?
    var artistCredit: [ArtistCredit]?
    var releases: [Release]?

    enum CodingKeys: String, CodingKey {
        case title
        case length
        case artistCredit = "artist-credit"
        case releases
    }
}

struct ArtistCredit: Codable {
    var name: String
    var artist: Artist?

    enum CodingKeys: String, CodingKey {
        case name
        case artist
    }
}

struct Artist: Codable {
    var id: String
    var name: String
    var sortName: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case sortName = "sort-name"
    }
}

struct Release: Codable {
    var coverArtArchive: CoverArtArchive?

    enum CodingKeys: String, CodingKey {
        case coverArtArchive = "cover-art-archive"
    }
}

struct CoverArtArchive: Codable {
    var front: String?
}

struct AddSongView_Previews: PreviewProvider {
    @State static var mockSongs = [Song]()
    
    static var previews: some View {
        AddSongView(songs: $mockSongs)
    }
}
