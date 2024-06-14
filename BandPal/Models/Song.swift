import Foundation

class Song: Identifiable, ObservableObject, Equatable {
    let id: UUID
    let title: String
    let artist: String
    @Published var albumArt: String?
    @Published var songDuration: Int?
    
    var formattedDuration: String {
        guard let duration = songDuration else { return "Duration not available" }
        let minutes = (duration / 1000) / 60
        let seconds = (duration / 1000) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    init(id: UUID = UUID(), title: String, artist: String, albumArt: String? = nil, songDuration: Int? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.albumArt = albumArt
        self.songDuration = songDuration
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id
    }
}
