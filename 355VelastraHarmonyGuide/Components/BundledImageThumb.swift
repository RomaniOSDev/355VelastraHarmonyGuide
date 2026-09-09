import SwiftUI

struct BundledImageThumb: View {
    let name: String

    var body: some View {
        Group {
            if NarrativeImage(rawValue: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFill()
            } else {
                Color("AppSurface")
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(Color("AppTextSecondary"))
                    }
            }
        }
    }
}
