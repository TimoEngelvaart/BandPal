import SwiftUI

struct CustomDatePickerModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            // Header with drag indicator
            VStack(spacing: 12) {
                // Drag indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                HStack {
                    Text("Select Date")
                        .font(.custom("Urbanist-Bold", size: 22))
                        .foregroundColor(colorScheme == .light ? Color(red: 0.13, green: 0.13, blue: 0.13) : .white)

                    Spacer()

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 20)

            // Date Picker - using .id() to prevent jumping
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(Color(red: 0.35, green: 0.3, blue: 0.96))
            .id(selectedDate) // Forces view recreation to prevent jump
            .padding(.horizontal, 20)
            .frame(height: 350)
            .clipped()

            // Set Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isPresented = false
                }
            }) {
                ButtonView(buttonText: "Set Date")
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(colorScheme == .dark ? Color(red: 0.12, green: 0.13, blue: 0.16) : Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: -5)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }
}

struct CustomDatePickerModal_Previews: PreviewProvider {
    @State static var isPresented = true
    @State static var selectedDate = Date()

    static var previews: some View {
        Group {
            CustomDatePickerModal(isPresented: $isPresented, selectedDate: $selectedDate)
                .preferredColorScheme(.light) // Preview in light mode
            CustomDatePickerModal(isPresented: $isPresented, selectedDate: $selectedDate)
                .preferredColorScheme(.dark) // Preview in dark mode
        }
    }
}
