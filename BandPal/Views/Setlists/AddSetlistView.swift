import SwiftUI
import SwiftData

struct AddSetlistView: View {
    @State private var title: String = ""
    @State private var selectedDate: Date = Date()
    @State private var validDate: Date?
    @State private var showDateError: Bool = false
    @State private var isDatePickerPresented: Bool = false
    @Environment(\.modelContext) private var modelContext

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var body: some View {
        VStack {
            SetListHeader(
                title: "Add Setlist",
                showTitle: true,
                showBackButton: true,
                showSearchButton: false,
                showFilter: false
            )
            .padding(.horizontal, 16)

            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                InputView(placeholder: "Enter Title", text: $title, onCommit: {})
                    .padding(.horizontal, 32)

                dateButton

                if showDateError {
                    dateErrorText
                }
            }

            Spacer()

            addButton
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            convertAndValidateDate(from: selectedDate)
        }
        .overlay(
            ZStack {
                if isDatePickerPresented {
                    VStack(spacing: 0) {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea(edges: .top)
                            .onTapGesture {
                                withAnimation {
                                    isDatePickerPresented = false
                                }
                            }
                        Spacer()
                    }

                    CustomDatePickerModal(isPresented: $isDatePickerPresented, selectedDate: $selectedDate)
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: isDatePickerPresented)
                }
            }
        )
    }

    private var dateButton: some View {
        Button(action: {
            withAnimation {
                isDatePickerPresented = true
            }
        }) {
            HStack {
                Text("Select Date: \(formattedDate(selectedDate))")
                    .font(.custom("Urbanist", size: 14).weight(.semibold))
                    .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
                    .kerning(0.2)
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
            .cornerRadius(16)
        }
        .padding(.horizontal, 32)
        .accessibility(label: Text("Select a date"))
    }

    private var dateErrorText: some View {
        Text("Invalid date format. Please use dd-MM-yyyy.")
            .foregroundColor(.red)
            .font(.system(size: 14, weight: .regular))
            .padding(.horizontal, 16)
    }

    private var addButton: some View {
        Button(action: addSetlist) {
            ButtonView(buttonText: "Add Setlist")
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
        }
    }

    private func addSetlist() {
        if let validDate = validDate, !title.isEmpty {
            let newSetlist = Setlist(title: title, date: validDate, songs: [])
            modelContext.insert(newSetlist)
            presentationMode.wrappedValue.dismiss()

            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else {
            // Show error message or highlight missing fields
            showDateError = title.isEmpty || validDate == nil
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }

    private func convertAndValidateDate(from date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let dateString = formatter.string(from: date)
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
    AddSetlistView()
        .modelContainer(for: [Setlist.self, Song.self], inMemory: true)
}
