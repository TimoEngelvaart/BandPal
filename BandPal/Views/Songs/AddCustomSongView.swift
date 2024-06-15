import SwiftUI
import PhotosUI

struct AddCustomSongView: View {
    @Binding var songs: [Song]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var duration: String = ""
    @State private var albumArt: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Custom Song")
                .font(.largeTitle)
                .padding(.bottom, 24)
            
            TextField("Song Title", text: $title)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            TextField("Artist", text: $artist)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            TextField("Duration (seconds)", text: $duration)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .keyboardType(.numberPad)
            
            if let albumArt = albumArt {
                Image(uiImage: albumArt)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .onTapGesture {
                        isImagePickerPresented = true
                    }
            } else {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    Text("Select Album Art")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Button(action: {
                addCustomSong()
            }) {
                Text("Add Song")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
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
        songs.append(newSong)
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
    @State static var mockSongs = [Song]()
    
    static var previews: some View {
        AddCustomSongView(songs: $mockSongs)
    }
}
