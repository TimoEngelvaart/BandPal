import Foundation

struct Setlist: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var setlist: [Song]
}

