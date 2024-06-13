import Foundation

struct Song: Identifiable {
    let id: UUID
    let title: String
    let artist: String
    let albumArt: String?
    let songDuration: Int?
    
    var formattedDuration: String? {
        guard let duration = songDuration else { return nil }
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
}
