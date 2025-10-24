import SwiftUI
import SwiftData

struct MemberPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<BandMember> { $0.isActive }, sort: \BandMember.name) private var allMembers: [BandMember]

    @Binding var selectedMembers: [BandMember]
    @State private var showingAddMember = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("Absent Members")
                        .font(.custom("Urbanist-SemiBold", size: 18))
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
                .padding()
                
                Divider()
                
                if allMembers.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "person.3")
                            .font(.custom("Urbanist-Regular", size: 60))
                            .foregroundColor(.secondary)
                        Text("No band members yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Tap below to add your first band member")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(allMembers, id: \.id) { member in
                            MemberPickerRow(
                                member: member,
                                isSelected: selectedMembers.contains(where: { $0.id == member.id }),
                                onToggle: {
                                    toggleMember(member)
                                }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteMember(member)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }

                // Add Member Button
                Button(action: {
                    showingAddMember = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.custom("Urbanist-Regular", size: 20))
                        Text("Add Band Member")
                            .font(.custom("Urbanist-SemiBold", size: 16))
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddMember) {
                AddBandMemberSheet()
            }
        }
    }
    
    private func toggleMember(_ member: BandMember) {
        if let index = selectedMembers.firstIndex(where: { $0.id == member.id }) {
            selectedMembers.remove(at: index)
        } else {
            selectedMembers.append(member)
        }
    }

    private func deleteMember(_ member: BandMember) {
        // Remove from selected members if they were selected
        if let index = selectedMembers.firstIndex(where: { $0.id == member.id }) {
            selectedMembers.remove(at: index)
        }

        // Delete from database
        modelContext.delete(member)
    }
}

struct MemberPickerRow: View {
    let member: BandMember
    let isSelected: Bool
    let onToggle: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.custom("Urbanist-SemiBold", size: 12))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(member.name)
                        .font(.custom("Urbanist-SemiBold", size: 16))
                        .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : .white)
                    
                    if let instrument = member.instrument, !instrument.isEmpty {
                        Text(instrument)
                            .font(.custom("Urbanist-Regular", size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
    }
}

struct AddBandMemberSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    @State private var name: String = ""
    @State private var instrument: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Add Band Member")
                        .font(.custom("Urbanist-SemiBold", size: 24))
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.custom("Urbanist-SemiBold", size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Spacer()

                // Form
                VStack(alignment: .leading, spacing: 16) {
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.custom("Urbanist-SemiBold", size: 12))
                            .foregroundColor(.secondary)

                        TextField("", text: $name)
                            .font(.custom("Urbanist-SemiBold", size: 14))
                            .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
                            .cornerRadius(16)
                            .overlay(
                                Group {
                                    if name.isEmpty {
                                        HStack {
                                            Text("e.g., John")
                                                .font(.custom("Urbanist-SemiBold", size: 14))
                                                .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.4) : Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.6))
                                                .padding(.leading, 16)
                                            Spacer()
                                        }
                                        .allowsHitTesting(false)
                                    }
                                }
                            )
                    }

                    // Instrument field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instrument (optional)")
                            .font(.custom("Urbanist-SemiBold", size: 12))
                            .foregroundColor(.secondary)

                        TextField("", text: $instrument)
                            .font(.custom("Urbanist-SemiBold", size: 14))
                            .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : Color(red: 0.62, green: 0.62, blue: 0.62))
                            .padding(.horizontal, 16)
                            .frame(height: 56)
                            .background(colorScheme == .light ? Color(red: 0.98, green: 0.98, blue: 0.98) : Color(red: 0.12, green: 0.13, blue: 0.16))
                            .cornerRadius(16)
                            .overlay(
                                Group {
                                    if instrument.isEmpty {
                                        HStack {
                                            Text("e.g., Guitar")
                                                .font(.custom("Urbanist-SemiBold", size: 14))
                                                .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13).opacity(0.4) : Color(red: 0.62, green: 0.62, blue: 0.62).opacity(0.6))
                                                .padding(.leading, 16)
                                            Spacer()
                                        }
                                        .allowsHitTesting(false)
                                    }
                                }
                            )
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                // Add Button
                Button(action: addMember) {
                    ButtonView(buttonText: "Add Member")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
            }
        }
    }

    private func addMember() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedInstrument = instrument.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else { return }

        let newMember = BandMember(
            name: trimmedName,
            instrument: trimmedInstrument.isEmpty ? nil : trimmedInstrument
        )

        modelContext.insert(newMember)

        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }
}
