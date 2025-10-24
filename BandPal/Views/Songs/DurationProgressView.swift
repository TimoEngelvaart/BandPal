import SwiftUI
import SwiftData

struct DurationProgressView: View {
    let setlist: Setlist
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Set Duration Goal")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Spacer()

                if setlist.targetDuration != nil {
                    Text("\(setlist.formattedTotalDuration) / \(setlist.formattedTargetDuration)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)

                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(statusColor)
                        .frame(width: min(geometry.size.width * setlist.progressPercentage, geometry.size.width), height: 12)
                        .animation(.spring(), value: setlist.progressPercentage)
                }
            }
            .frame(height: 12)

            Text(setlist.durationStatus.rawValue)
                .font(.caption)
                .foregroundColor(statusColor)
        }
        .padding(12)
        .background(colorScheme == .dark ? Color(red: 0.12, green: 0.13, blue: 0.16) : Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var statusColor: Color {
        switch setlist.durationStatus {
        case .noTarget:
            return .gray
        case .underTarget:
            return .orange
        case .onTarget:
            return .green
        case .overTarget:
            return .red
        }
    }
}
