import SwiftUI
import SwiftData

//To make swipe action available
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

struct SetlistView: View {
    @Binding var selectedTab: Int
    @Query(sort: \Setlist.date, order: .reverse) var setlists: [Setlist]
    @Query private var bands: [Band]
    @Environment(\.modelContext) private var modelContext
    @AppStorage("activeBandID") private var activeBandID: String = ""
    @State private var activeSetlist: Setlist?
    @State private var showBandList = false
    @State private var selectedStatus: String = "Upcoming"
    let globalHorizontalPadding: CGFloat = 16 // Use this value for consistency

    // Get active band
    private var activeBand: Band? {
        bands.first { $0.id.uuidString == activeBandID }
    }

    // Filter setlists by status
    private var filteredSetlists: [Setlist] {
        // Get today at midnight for accurate date comparison
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        switch selectedStatus {
        case "Upcoming":
            return setlists.filter { $0.date >= today }
        case "Completed":
            return setlists.filter { $0.date < today }
        default:
            return setlists
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header with band settings
                HStack {
                    Text("Setlists")
                        .font(.custom("Urbanist-SemiBold", size: 24))
                    Spacer()
                    Button {
                        showBandList = true
                    } label: {
                        Image(systemName: "person.2")
                            .font(.custom("Urbanist-Regular", size: 22))
                            .foregroundColor(.primary)
                    }
                }
                .frame(minHeight: 48, maxHeight: 48)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)

                // Status tabs
                StatusView(selectedStatus: $selectedStatus)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                List(filteredSetlists) { setlist in
                    ZStack {
                        // Invisible NavigationLink
                        NavigationLink(destination: SongsView(setlist: setlist)) {
                              EmptyView()
                          }
                        .opacity(0) // Make the NavigationLink invisible

                        // Button that looks like your list item view
                        Button(action: {
                            self.activeSetlist = setlist
                        }) {
                            SetlistItemView(setlistItem: setlist)
                                .padding(.horizontal, 12)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            modelContext.delete(setlist)
                        } label: {
                            Image(systemName: "trash")
                        }
                    }

                }
                .refreshable {
                    await syncSetlists()
                }
                .listStyle(PlainListStyle())
            }
          
            NavigationLink(destination: AddSetlistView()) {
                ButtonView(buttonText: "Add Setlist")
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showBandList) {
            BandListView()
        }
    }

    private func syncSetlists() async {
        guard let activeBand = activeBand else { return }

        do {
            try await BandSharingManager.shared.performFullSync(for: activeBand, context: modelContext)
            print("✅ Manual sync completed")
        } catch {
            print("⚠️ Manual sync failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SetlistView(selectedTab: .constant(0))
        .modelContainer(for: [Setlist.self, Song.self], inMemory: true)
}
