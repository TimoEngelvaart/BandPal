import SwiftUI

struct CustomDatePickerModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                        .padding()
                }
            }
            .background(Color.gray.opacity(0.2))

            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden()
            .padding()

            Button(action: {
                isPresented = false
            }) {
                Text("Set")
                    .font(.custom("Urbanist", size: 16).weight(.bold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .background(Color.white)
        .cornerRadius(16)
        .padding()
    }
}
