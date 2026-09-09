import SwiftUI

struct EmptyStateBlock: View {
    let symbol: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 36))
                .foregroundColor(Color("AppPrimary"))
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
    }
}
