import SwiftUI

struct LastFMSearchResults: Codable {
    let results: Results

    struct Results: Codable {
        let trackmatches: TrackMatches

        struct TrackMatches: Codable {
            let track: [Track]

            struct Track: Codable {
                let name: String
                let artist: String
                let image: [Image]

                struct Image: Codable {
                    let text: String
                    let size: String

                    enum CodingKeys: String, CodingKey {
                        case text = "#text"
                        case size
                    }
                }
            }
        }
    }
}


struct AddSongView: View {
    @State private var searchQuery: String = ""
    @State private var searchResults: [Song] = []
    @State private var searchDebounce: DispatchWorkItem?
    @Binding var songs: [Song]
    
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
            if !searchResults.isEmpty {
                List(searchResults, id: \.id) { song in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(song.title)
                            Text(song.artist).font(.subheadline).foregroundColor(.gray)
                            if let duration = song.formattedDuration {
                                Text(duration).font(.caption).foregroundColor(.gray)
                            }
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
    
    private func onSearchQueryChange(_ newValue: String) {
        searchDebounce?.cancel()
        
        guard newValue.count >= 3 else {
            searchResults = []
            return
        }
        
        let workItem = DispatchWorkItem {
            self.searchMusic(query: newValue)
        }
        
        searchDebounce = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    private func searchMusic(query: String) {
        let apiKey = "" // Replace with your Last.fm API key
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "http://ws.audioscrobbler.com/2.0/?method=track.search&track=\(encodedQuery)&api_key=\(apiKey)&format=json"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Network error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("Server returned status code: \(httpResponse.statusCode)")
                return
            }
            
            if let data = data {
                // Print JSON for debugging
                if let jsonStr = String(data: data, encoding: .utf8) {
                    print("Last.fm JSON response: \(jsonStr)")
                }
                
                do {
                    let searchResults = try JSONDecoder().decode(LastFMSearchResults.self, from: data)
                    DispatchQueue.main.async {
                        self.searchResults = searchResults.results.trackmatches.track.map { track in
                            let albumArt = track.image.first { $0.size == "large" }?.text
                            // Mock duration as Last.fm doesn't provide it
                            let duration = Int.random(in: 180000...240000) // Mock duration between 3-4 minutes
                            return Song(title: track.name,
                                        artist: track.artist,
                                        albumArt: albumArt,
                                        songDuration: duration)
                        }
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        
        task.resume()
    }
}

struct AddSongView_Previews: PreviewProvider {
    @State static var mockSongs = [Song]()
    
    static var previews: some View {
        AddSongView(songs: $mockSongs)
    }
}
