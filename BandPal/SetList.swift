import Foundation

struct SetList {
    var ID = UUID()
    var title: String
    var songs: [Song]
}

struct Song {
    var title: String
    var Artist: String
}


