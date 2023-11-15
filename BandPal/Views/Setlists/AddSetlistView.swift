import SwiftUI

struct AddSetlistView: View {
    @State private var title: String = ""
    @State private var dateString: String = ""
    @State private var validDate: Date?
    @State private var showDateError: Bool = false
    @Binding var setlists: [Setlist]

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            InputView(placeholder: "Enter Title", text: $title, onCommit: {})
            InputView(placeholder: "Enter Date (dd-MM-yyyy)", text: $dateString, onCommit: {})
                .onChange(of: dateString) { newValue in
                    self.convertAndValidateDate(from: newValue)
                }
            if showDateError {
                Text("Invalid date format. Please use dd-MM-yyyy.")
                    .foregroundColor(.red)
            }

            Button(action: {
                if let validDate = validDate, !title.isEmpty {
                    let newSetlist = Setlist(title: title, date: validDate, setlist: [])
                    setlists.append(newSetlist)
                    presentationMode.wrappedValue.dismiss()
                }
                // You might want to handle the else case, maybe show an error message.
            }) {
                ButtonView(buttonText: "Test")
            }
        }
    }

    private func convertAndValidateDate(from dateString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if let date = formatter.date(from: dateString) {
            validDate = date
            showDateError = false
        } else {
            validDate = nil
            showDateError = true
        }
    }
}

#Preview {
    AddSetlistView(setlists: .constant([]))
}
