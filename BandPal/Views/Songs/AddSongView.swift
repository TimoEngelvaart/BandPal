import SwiftUI

struct AddSongView: View {
    @State private var songName: String = ""
    @State private var artistName: String = ""
    @State private var albumArt: String? // To hold the URL of the album art
    @State private var songDuration: Int? // To hold the song duration
    @State private var albumName: String = ""
    @Binding var songs: [Song]
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    func onSongInfoChange() {
        guard !songName.isEmpty, !artistName.isEmpty, !albumName.isEmpty else {
            return
        }
        fetchMusicInfo(song: songName, artist: artistName, album: albumName)
    }

    var body: some View {
        
        VStack(alignment: .leading, spacing: 24)  {
            SetListHeader(title: "Test", showSearchButton: false, showFilter: false)
                .padding(.bottom, 24)
            // Header
            Text("Song Information")
                .font(Font.custom("Urbanist-Light", size: 16))
                .kerning(0.2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
     
            // Input field
            InputView(placeholder: "Enter Song Name", text: $songName, onCommit: {})
                .onChange(of: songName) { onSongInfoChange() }

            InputView(placeholder: "Enter Artist Name", text: $artistName, onCommit: {})
                .onChange(of: artistName) { onSongInfoChange() }

            InputView(placeholder: "Enter Album Name", text: $albumName, onCommit: {})
                .onChange(of: albumName) { onSongInfoChange() }

            Button(action: {
                let newSong = SetListItem(title: songName, artist: artistName, albumArt: albumArt, songDuration: songDuration)
                setListItems.append(newSong)
                self.presentationMode.wrappedValue.dismiss()
            }) {
                ButtonView()
            }
            
            // Display the album art
            if let albumArtURL = albumArt, let url = URL(string: albumArtURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.horizontal, 24)
                    case .failure:
                        Text("Failed to load")
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Text("Album art not available")
                    .padding(.horizontal, 24)
            }
            
            // Display the song duration
            if let duration = songDuration {
                let minutes = (duration / 1000) / 60
                let seconds = (duration / 1000) % 60
                Text("Song Duration: \(minutes)m \(seconds)s")
                    .padding(.horizontal, 24)
            } else {
                Text("Song duration not available")
                    .padding(.horizontal, 24)
            }
                
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
    }
    func fetchMusicInfo(song: String, artist: String, album: String) {
        let query = "artist:\(artist) AND recording:\(song) AND release:\(album)"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://musicbrainz.org/ws/2/recording/?query=\(encodedQuery)&fmt=json&limit=1"
        
        // Print the query
        print("Executing MusicBrainz API query: \(urlString)")

        
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
                   let jsonStr = String(data: data, encoding: .utf8)
                   print("MusicBrainz JSON response: \(jsonStr ?? "Unknown")")
                   do {
                       let searchResults = try JSONDecoder().decode(MusicBrainzSearchResults.self, from: data)
                       if let firstRecording = searchResults.recordings.first,
                          let firstRelease = firstRecording.releases.first,
                          let mbid = firstRelease.id {
                               fetchCoverArt(mbid: mbid)
                               if let duration = firstRecording.length {
                                   DispatchQueue.main.async {
                                       self.songDuration = duration
                                   }
                               }
                       }

                   } catch {
                       print("Error decoding JSON: \(error)")
                   }
            }
        }
        
        task.resume()
    }
    func fetchCoverArt(mbid: String) {
        let urlString = "https://coverartarchive.org/release/\(mbid)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Check for network error
            if let error = error {
                print("Network error: \(error)")
                return
            }
            
            // Check for HTTP status code
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("Server returned status code: \(httpResponse.statusCode)")
                return
            }
            
            // Check for valid JSON data
            if let data = data {
                // Print JSON for debugging
                let jsonStr = String(data: data, encoding: .utf8)
                print("CoverArt JSON response: \(jsonStr ?? "Unknown")")
                do {
                    let coverArtData = try JSONDecoder().decode(CoverArtData.self, from: data)
                    if let firstImage = coverArtData.images.first {
                        DispatchQueue.main.async {
                            self.albumArt = firstImage.image
                            print("Updated albumArt: \(self.albumArt ?? "N/A")")
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

struct CoverArtData: Codable {
    var images: [CoverArtImage]
}

struct CoverArtImage: Codable {
    var image: String
}


// Define the data model based on MusicBrainz API JSON structure.
struct MusicBrainzSearchResults: Codable {
    var recordings: [Recording]
}

struct Recording: Codable {
    var length: Int?
    var releases: [Release]
}

struct Release: Codable {
    var id: String?
    var title: String?  // Adding this to store the album name
    var coverArtArchive: CoverArtArchive?
}

struct CoverArtArchive: Codable {
    var front: String?
}

