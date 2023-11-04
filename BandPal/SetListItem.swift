import Foundation

struct SetListItem: Identifiable  {
    let id = UUID()
    let title: String
    let artist: String
    let albumArt: String? 
    let songDuration: Int?
    
    // Computed property to get formatted song duration
        var formattedDuration: String {
            guard let duration = songDuration else { return "Duration not available" }
            let minutes = (duration / 1000) / 60
            let seconds = (duration / 1000) % 60
            return "\(minutes)m \(seconds)s"
        }
}
