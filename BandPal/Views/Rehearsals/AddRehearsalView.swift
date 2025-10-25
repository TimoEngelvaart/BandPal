import SwiftUI
import SwiftData

struct AddRehearsalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Query private var bands: [Band]
    @AppStorage("activeBandID") private var activeBandID: String = ""

    @State private var selectedAbsentMembers: [BandMember] = []
    @State private var notes: String = ""
    @State private var selectedDate: Date = nextFriday()
    @State private var validDate: Date?
    @State private var showDateError: Bool = false
    @State private var isDatePickerPresented: Bool = false
    @State private var showMemberPicker: Bool = false
    @State private var repeatFrequency: RepeatFrequency = .none
    @State private var numberOfOccurrences: Int = 1

    // Get active band
    private var activeBand: Band? {
        bands.first { $0.id.uuidString == activeBandID }
    }

    enum RepeatFrequency: String, CaseIterable {
        case none = "None"
        case weekly = "Weekly"
        case biweekly = "Every 2 weeks"
        case monthly = "Monthly"

        var days: Int {
            switch self {
            case .none: return 0
            case .weekly: return 7
            case .biweekly: return 14
            case .monthly: return 30
            }
        }
    }

    // Static cached formatters for performance
    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()

    private static let validationFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            SetListHeader(
                title: "Add Rehearsal",
                showTitle: true,
                showBackButton: true,
                showSearchButton: false,
                showFilter: false
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            Spacer()

            // Form
            VStack(alignment: .leading, spacing: 16) {
                dateButton

                if showDateError {
                    dateErrorText
                }

                // Repeat frequency picker
                repeatFrequencyPicker

                // Number of occurrences (only show if repeat is enabled)
                if repeatFrequency != .none {
                    numberOfOccurrencesField
                }

                // Absent members picker button
                absentMembersButton

                // Notes input
                notesField
            }
            .padding(.horizontal, 16)

            Spacer()

            // Add Button
            Button(action: addRehearsal) {
                ButtonView(buttonText: repeatFrequency == .none ? "Add Rehearsal" : "Add \(numberOfOccurrences) Rehearsals")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            convertAndValidateDate(from: selectedDate)
        }
        .onChange(of: selectedDate) { _, newDate in
            convertAndValidateDate(from: newDate)
        }
        .overlay {
            if isDatePickerPresented {
                ZStack {
                    // Full-screen dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isDatePickerPresented = false
                            }
                        }

                    // Date picker modal centered
                    VStack {
                        Spacer()
                        CustomDatePickerModal(isPresented: $isDatePickerPresented, selectedDate: $selectedDate)
                        Spacer()
                            .frame(height: 40)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isDatePickerPresented)
    }

    private var dateButton: some View {
        Button(action: {
            withAnimation {
                isDatePickerPresented = true
            }
        }) {
            HStack {
                Text("Select Date: \(formattedDate(selectedDate))")
                    .font(.custom("Urbanist-SemiBold", size: 14))
                    .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
            .cornerRadius(16)
        }
        .accessibility(label: Text("Select a date"))
    }

    private var notesField: some View {
        TextEditor(text: $notes)
            .font(.custom("Urbanist-SemiBold", size: 14))
            .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(height: 100)
            .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
            .cornerRadius(16)
            .scrollContentBackground(.hidden)
            .overlay(alignment: .topLeading) {
                if notes.isEmpty {
                    Text("Notes (optional)")
                        .font(.custom("Urbanist-SemiBold", size: 14))
                        .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.4) : Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .allowsHitTesting(false)
                }
            }
    }

    private var dateErrorText: some View {
        Text("Invalid date format. Please use dd-MM-yyyy.")
            .foregroundColor(.red)
            .font(.custom("Urbanist-Regular", size: 14))
    }

    private var repeatFrequencyPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repeat")
                .font(.custom("Urbanist-SemiBold", size: 12))
                .foregroundColor(.secondary)

            Menu {
                ForEach(RepeatFrequency.allCases, id: \.self) { frequency in
                    Button(action: {
                        repeatFrequency = frequency
                        if frequency == .none {
                            numberOfOccurrences = 1
                        }
                    }) {
                        HStack {
                            Text(frequency.rawValue)
                            if repeatFrequency == frequency {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(repeatFrequency.rawValue)
                        .font(.custom("Urbanist-SemiBold", size: 14))
                        .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.custom("Urbanist-Regular", size: 14))
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
                .cornerRadius(16)
            }
        }
    }

    private var numberOfOccurrencesField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Number of rehearsals")
                .font(.custom("Urbanist-SemiBold", size: 12))
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button(action: {
                    if numberOfOccurrences > 1 {
                        numberOfOccurrences -= 1
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.custom("Urbanist-Regular", size: 32))
                        .foregroundColor(numberOfOccurrences > 1 ? .blue : .gray.opacity(0.3))
                }
                .disabled(numberOfOccurrences <= 1)

                Text("\(numberOfOccurrences)")
                    .font(.custom("Urbanist-SemiBold", size: 24))
                    .frame(minWidth: 60)
                    .foregroundColor(.primary)

                Button(action: {
                    if numberOfOccurrences < 52 {
                        numberOfOccurrences += 1
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.custom("Urbanist-Regular", size: 32))
                        .foregroundColor(numberOfOccurrences < 52 ? .blue : .gray.opacity(0.3))
                }
                .disabled(numberOfOccurrences >= 52)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    private var absentMembersButton: some View {
        Button(action: {
            showMemberPicker = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Absent Members")
                        .font(.custom("Urbanist-SemiBold", size: 12))
                        .foregroundColor(.secondary)

                    if selectedAbsentMembers.isEmpty {
                        Text("Tap to select")
                            .font(.custom("Urbanist-SemiBold", size: 14))
                            .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.4) : Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.6))
                    } else {
                        Text(selectedAbsentMembers.map { $0.name }.joined(separator: ", "))
                            .font(.custom("Urbanist-SemiBold", size: 14))
                            .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
                            .lineLimit(2)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.custom("Urbanist-Regular", size: 14))
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 56)
            .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
            .cornerRadius(16)
        }
        .sheet(isPresented: $showMemberPicker) {
            MemberPickerSheet(selectedMembers: $selectedAbsentMembers)
        }
    }

    private func addRehearsal() {
        guard let validDate = validDate else {
            // Show error message
            showDateError = true
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }

        // Create rehearsals based on repeat settings
        let calendar = Calendar.current

        if repeatFrequency == .none {
            // Create single rehearsal
            let newRehearsal = Rehearsal(
                date: validDate,
                absentMembers: selectedAbsentMembers,
                notes: notes.isEmpty ? nil : notes,
                newSongs: [],
                oldSongs: []
            )

            // Link to active band
            if let activeBand = activeBand {
                newRehearsal.band = activeBand

                // Sync to CloudKit
                Task {
                    do {
                        try await BandSharingManager.shared.syncRehearsal(newRehearsal, for: activeBand)
                    } catch {
                        print("Warning: Could not sync rehearsal: \(error)")
                    }
                }
            }

            modelContext.insert(newRehearsal)
        } else {
            // Create multiple rehearsals
            for i in 0..<numberOfOccurrences {
                let offsetDays = i * repeatFrequency.days
                if let rehearsalDate = calendar.date(byAdding: .day, value: offsetDays, to: validDate) {
                    let newRehearsal = Rehearsal(
                        date: rehearsalDate,
                        absentMembers: selectedAbsentMembers,
                        notes: notes.isEmpty ? nil : notes,
                        newSongs: [],
                        oldSongs: []
                    )

                    // Link to active band
                    if let activeBand = activeBand {
                        newRehearsal.band = activeBand

                        // Sync to CloudKit
                        Task {
                            do {
                                try await BandSharingManager.shared.syncRehearsal(newRehearsal, for: activeBand)
                            } catch {
                                print("Warning: Could not sync rehearsal: \(error)")
                            }
                        }
                    }

                    modelContext.insert(newRehearsal)
                }
            }
        }

        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }

    private func formattedDate(_ date: Date) -> String {
        Self.displayFormatter.string(from: date)
    }

    private func convertAndValidateDate(from date: Date) {
        let dateString = Self.validationFormatter.string(from: date)
        if let date = Self.validationFormatter.date(from: dateString) {
            validDate = date
            showDateError = false
        } else {
            validDate = nil
            showDateError = true
        }
    }

    // Helper function to get next Friday
    private static func nextFriday() -> Date {
        let calendar = Calendar.current
        let today = Date()

        // Get current weekday (1 = Sunday, 6 = Friday)
        let currentWeekday = calendar.component(.weekday, from: today)

        // Calculate days until Friday (6)
        let daysUntilFriday: Int
        if currentWeekday < 6 {
            daysUntilFriday = 6 - currentWeekday
        } else {
            daysUntilFriday = 7 - currentWeekday + 6
        }

        return calendar.date(byAdding: .day, value: daysUntilFriday, to: today) ?? today
    }
}

#Preview {
    AddRehearsalView()
}
