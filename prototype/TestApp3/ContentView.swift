import SwiftUI

struct ContentView: View {
    var body: some View {
        CameraViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Nothing to update
    }
}
