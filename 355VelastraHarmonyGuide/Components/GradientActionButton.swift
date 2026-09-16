import SwiftUI

struct GradientActionButton: View {
    let title: String
    let systemImage: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.body.weight(.semibold))
            }
            .foregroundColor(Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [
                        Color("AppPrimary").opacity(isEnabled ? 1 : 0.4),
                        Color("AppAccent").opacity(isEnabled ? 1 : 0.4)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
