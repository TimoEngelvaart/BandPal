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
    let globalHorizontalPadding: CGFloat = 16 // Use this value for consistency

    // Get active band
    private var activeBand: Band? {
        bands.first { $0.id.uuidString == activeBandID }
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
                  

                List(setlists) { setlist in
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
                                .padding(.top, 16)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets()) // Remove default padding to extend swipe area
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            modelContext.delete(setlist)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                
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
}

#Preview {
    SetlistView(selectedTab: .constant(0))
        .modelContainer(for: [Setlist.self, Song.self], inMemory: true)
}
