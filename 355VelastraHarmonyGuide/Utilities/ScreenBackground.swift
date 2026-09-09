import SwiftUI
import UIKit

struct ScreenBackdrop: View {
    var image: String = "bg_banquet"

    var body: some View {
        GeometryReader { proxy in
            Image(image)
                .resizable()
                .scaledToFill()
                .overlay {
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.18),
                            Color.black.opacity(0.32)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

enum DockClearance {
    static let height: CGFloat = 118
}

extension View {
    func screenBackground(_ image: String = "bg_banquet") -> some View {
        self
            .toolbarBackground(.hidden, for: .navigationBar)
            .background(NavigationSurfaceClearer())
            .background {
                ScreenBackdrop(image: image)
            }
    }

    func screenCanvas(_ image: String = "bg_banquet") -> some View {
        self
            .scrollContentBackground(.hidden)
            .toolbarBackground(.hidden, for: .navigationBar)
            .background {
                ScreenBackdrop(image: image)
            }
            .clearsFloatingDock()
    }

    func clearsFloatingDock() -> some View {
        self.safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear
                .frame(height: DockClearance.height)
                .allowsHitTesting(false)
        }
    }
}

private struct NavigationSurfaceClearer: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            var node: UIView? = view.superview
            while let current = node {
                if let window = current as? UIWindow {
                    window.backgroundColor = UIColor(red: 0.12, green: 0.07, blue: 0.08, alpha: 1)
                    break
                }
                if !(current is UIImageView) {
                    current.backgroundColor = .clear
                }
                node = current.superview
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
