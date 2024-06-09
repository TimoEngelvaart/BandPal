import SwiftUI

struct CustomDatePickerModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date

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
        .background(Color.white)
        .cornerRadius(16)
        .padding()
        .frame(maxHeight: .infinity) // Ensures the modal reaches the bottom
        .ignoresSafeArea(.container, edges: .bottom) // Ensures it uses the full height
    }
}

struct CustomDatePickerModal_Previews: PreviewProvider {
    @State static var isPresented = true
    @State static var selectedDate = Date()

    static var previews: some View {
        CustomDatePickerModal(isPresented: $isPresented, selectedDate: $selectedDate)
    }
}
