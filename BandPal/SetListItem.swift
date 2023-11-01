import Foundation

struct SetListItem: Identifiable  {
    let id = UUID()
    let title: String
    let artist: String
    let albumArt: String? 
    let songDuration: Int?
}
