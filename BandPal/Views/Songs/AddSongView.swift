import SwiftUI

// iTunes Search API Response
struct iTunesSearchResults: Codable {
    let results: [iTunesTrack]
}

struct iTunesTrack: Codable {
    let trackName: String
    let artistName: String
    let artworkUrl100: String?
    let trackTimeMillis: Int?
    let collectionName: String?
}

struct AddSongView: View {
    @State private var searchQuery: String = ""
    @State private var searchResults: [Song] = []
    @State private var searchDebounce: DispatchWorkItem?
    @State private var searchPerformed: Bool = false
    @Binding var songs: [Song]?
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
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
                .onChange(of: searchQuery) { newValue in
                    self.onSearchQueryChange(newValue)
                }
            
            // Search Results
            if searchPerformed {
                if searchResults.isEmpty {
                    Text("No results found")
                        .padding(.horizontal, 16)
                } else {
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
                            if songs == nil {
                                songs = []
                            }
                            songs?.append(song)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }

            // Button to navigate to custom song addition view
            NavigationLink(destination: AddCustomSongView(songs: $songs)) {
                ButtonView(buttonText: "Add Custom Song")
                    .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func onSearchQueryChange(_ newValue: String) {
        searchDebounce?.cancel()
        
        guard newValue.count >= 3 else {
            searchResults = []
            searchPerformed = false
            return
        }
        
        let workItem = DispatchWorkItem {
            self.searchMusic(query: newValue)
        }
        
        searchDebounce = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    private func searchMusic(query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://itunes.apple.com/search?term=\(encodedQuery)&media=music&entity=song&limit=25"

        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Network error: \(error)")
                return
            }

            guard let data = data else { return }

            do {
                let searchResults = try JSONDecoder().decode(iTunesSearchResults.self, from: data)
                DispatchQueue.main.async {
                    self.searchResults = searchResults.results.map { track in
                        Song(
                            title: track.trackName,
                            artist: track.artistName,
                            albumArt: track.artworkUrl100,
                            songDuration: track.trackTimeMillis
                        )
                    }
                    self.searchPerformed = true
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }

        task.resume()
    }
}

struct AddSongView_Previews: PreviewProvider {
    @State static var mockSongs: [Song]? = []

    static var previews: some View {
        AddSongView(songs: $mockSongs)
    }
}
