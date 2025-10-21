import SwiftUI
import ARKit

struct ContentView: View {
    @State private var isProjecting = false
    @State private var selectedMedia: String = "gradient"
    @State private var showAlert = false
    @State private var alertMessage = ""

    let mediaOptions = ["gradient", "grid", "checkerboard"]

    var body: some View {
        ZStack {
            // AR View
            ARProjectionView(isProjecting: $isProjecting, selectedMedia: $selectedMedia)
                .edgesIgnoringSafeArea(.all)

            // UI Controls Overlay
            VStack {
                // Top Bar
                HStack {
                    Text("Projection Mapping")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(10)

                    Spacer()

                    Button(action: {
                        checkARSupport()
                    }) {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding()

                Spacer()

                // Bottom Controls
                VStack(spacing: 15) {
                    // Media Selector
                    HStack {
                        Text("Pattern:")
                            .foregroundColor(.white)
                            .font(.subheadline)

                        Picker("Media", selection: $selectedMedia) {
                            ForEach(mediaOptions, id: \.self) { option in
                                Text(option.capitalized).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(10)

                    // Projection Toggle Button
                    Button(action: {
                        isProjecting.toggle()
                    }) {
                        HStack {
                            Image(systemName: isProjecting ? "stop.circle.fill" : "play.circle.fill")
                                .font(.title2)
                            Text(isProjecting ? "Stop Projection" : "Start Projection")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isProjecting ? Color.red : Color.blue)
                        .cornerRadius(15)
                    }

                    // Instructions
                    Text("Point camera at flat surface to detect planes")
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.black.opacity(0.4))
                .cornerRadius(20)
                .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("AR Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func checkARSupport() {
        if ARWorldTrackingConfiguration.isSupported {
            alertMessage = "AR is supported on this device.\n\nThis app uses ARKit to detect flat surfaces and project patterns onto them.\n\nMove your device slowly to scan the environment."
        } else {
            alertMessage = "AR is not supported on this device. ARKit requires an A9 chip or later."
        }
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
