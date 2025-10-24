import Foundation
import SwiftData

struct SampleDataProvider {
    static func createSampleData(in context: ModelContext) {
        // Sample songs
        let song1 = Song(
            title: "Levels",
            artist: "Avicii",
            albumArt: "https://lastfm.freetls.fastly.net/i/u/174s/2a96cbd8b46e442fc41c2b86b821562f.png",
            songDuration: 202000
        )

        let song2 = Song(
            title: "Wake Me Up",
            artist: "Avicii",
            albumArt: "https://lastfm.freetls.fastly.net/i/u/174s/2a96cbd8b46e442fc41c2b86b821562f.png",
            songDuration: 247000
        )

        let song3 = Song(
            title: "Hey Brother",
            artist: "Avicii",
            albumArt: "https://lastfm.freetls.fastly.net/i/u/174s/2a96cbd8b46e442fc41c2b86b821562f.png",
            songDuration: 254000
        )

        let song4 = Song(
            title: "Sweet Dreams",
            artist: "Eurythmics",
            albumArt: nil,
            songDuration: 216000
        )

        let song5 = Song(
            title: "Mr. Brightside",
            artist: "The Killers",
            albumArt: nil,
            songDuration: 222000
        )

        // Sample setlist 1 - With target duration
        let setlist1 = Setlist(
            title: "Voorste Venne",
            date: Date().addingTimeInterval(7 * 24 * 60 * 60), // 1 week from now
            songs: [song1, song2, song3],
            targetDuration: 45 * 60, // 45 minutes
            venue: "Voorste Venne Pub"
        )

        // Sample setlist 2 - No target
        let setlist2 = Setlist(
            title: "De Mads",
            date: Date().addingTimeInterval(14 * 24 * 60 * 60), // 2 weeks from now
            songs: [song4, song5],
            venue: "De Mads Café"
        )

        // Sample setlist 3 - Empty (for testing)
        let setlist3 = Setlist(
            title: "Practice Session",
            date: Date(),
            songs: [],
            targetDuration: 30 * 60 // 30 minutes
        )

        // Insert sample data
        context.insert(setlist1)
        context.insert(setlist2)
        context.insert(setlist3)

        do {
            try context.save()
        } catch {
            print("Failed to create sample data: \(error)")
        }
    }
}
