import SwiftUI

struct CustomDatePickerModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .padding()
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }

            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden()
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(16)

            Button(action: {
                withAnimation {
                    isPresented = false
                }
            }) {
                ButtonView(buttonText: "Set")
            }
            .padding()
            Spacer()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(16)
        .padding()
        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
        .frame(maxHeight: .infinity) // Ensures the modal reaches the bottom
        .ignoresSafeArea(.container, edges: .bottom) // Ensures it uses the full height
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
