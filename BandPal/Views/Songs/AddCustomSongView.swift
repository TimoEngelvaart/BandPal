import SwiftUI
import PhotosUI

struct AddCustomSongView: View {
    @Binding var songs: [Song]?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var duration: String = ""
    @State private var albumArt: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            SetListHeader(
                title: "Add Custom Song",
                showTitle: true,
                showBackButton: true,
                showSearchButton: false,
                showFilter: false
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 24)

            Spacer()

            // Form
            VStack(alignment: .leading, spacing: 16) {
                InputView(placeholder: "Song Title", text: $title, onCommit: {})

                InputView(placeholder: "Artist", text: $artist, onCommit: {})

                InputView(placeholder: "Duration (seconds)", text: $duration, onCommit: {})

                // Album Art Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Album Art")
                        .font(.custom("Urbanist-SemiBold", size: 14))
                        .foregroundColor(.secondary)

                    if let albumArt = albumArt {
                        HStack {
                            Image(uiImage: albumArt)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text("Tap to change")
                                .font(.custom("Urbanist-Regular", size: 14))
                                .foregroundColor(.secondary)

                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isImagePickerPresented = true
                        }
                    } else {
                        Button(action: {
                            isImagePickerPresented = true
                        }) {
                            HStack {
                                Image(systemName: "photo")
                                    .foregroundColor(.secondary)
                                Text("Select Album Art")
                                    .font(.custom("Urbanist-Regular", size: 14))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(16)
                            .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
                            .cornerRadius(16)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer()

            // Add Button
            Button(action: {
                addCustomSong()
            }) {
                ButtonView(buttonText: "Add Song")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $albumArt)
        }
    }
    
    private func addCustomSong() {
        guard !title.isEmpty, !artist.isEmpty, let duration = Int(duration) else {
            // Handle invalid input
            return
        }
        
        let newSong = Song(title: title, artist: artist, albumArt: albumArt != nil ? albumArt!.toBase64() : nil, songDuration: duration * 1000)
        if songs == nil {
            songs = []
        }
        songs?.append(newSong)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var image: UIImage?
        
        init(image: Binding<UIImage?>) {
            _image = image
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                image = uiImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(image: $image)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

extension UIImage {
    func toBase64() -> String? {
        return self.jpegData(compressionQuality: 1.0)?.base64EncodedString()
    }
}

// Mock data for preview
//struct Song: Identifiable, ObservableObject {
//    let id = UUID()
//    let title: String
//    let artist: String
//    @Published var albumArt: String?
//    @Published var songDuration: Int?
//}

struct AddCustomSongView_Previews: PreviewProvider {
    @State static var mockSongs: [Song]? = []

    static var previews: some View {
        AddCustomSongView(songs: $mockSongs)
    }
}
