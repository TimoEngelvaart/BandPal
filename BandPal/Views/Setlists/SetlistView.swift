import SwiftUI

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
    @State var setlists: [Setlist] = []
    @State private var activeSetlist: Setlist?
    let globalHorizontalPadding: CGFloat = 16 // Use this value for consistency
    

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) { // Alignment to leading for VStack
                   SetListHeader(title: "Setlists", showBackButton: false, showFilter: false)
                    .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .leading)
                       .padding(.horizontal, globalHorizontalPadding)
                       .padding(.bottom, 16)
                
                StatusView()
                    .padding(.horizontal, globalHorizontalPadding)
                  

                List(setlists) { setlist in
                    ZStack {
                        // Invisible NavigationLink
                        NavigationLink(destination: SongsView(songs: setlist.setlist)) {
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
                            if let index = setlists.firstIndex(where: { $0.id == setlist.id }) {
                                setlists.remove(at: index)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                
                }
                
                .listStyle(PlainListStyle())
            }
          
            NavigationLink(destination: AddSetlistView(setlists: $setlists)) {
                ButtonView(buttonText: "Add Setlist")
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            BottomBorderView()
        }
    }
}

#Preview {
    SetlistView(setlists: [Setlist(title: "Voorste Venne", date: Date(), setlist: [Song(title: "Heaven", artist: "Avicii", albumArt: nil, songDuration: 30000), ]), Setlist(title: "De Mads", date: Date(), setlist: [Song(title: "Heaven", artist: "Avicii", albumArt: nil, songDuration: 300000), ])])
}
