import SwiftUI
import ARKit

struct ARProjectionView: UIViewControllerRepresentable {
    @Binding var isProjecting: Bool
    @Binding var selectedMedia: String

    func makeUIViewController(context: Context) -> ProjectionViewController {
        let viewController = ProjectionViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: ProjectionViewController, context: Context) {
        uiViewController.updateProjection(isProjecting: isProjecting, media: selectedMedia)
    }
}
