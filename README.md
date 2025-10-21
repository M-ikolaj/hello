# iOS Projection Mapping App

A powerful iOS application that uses ARKit to detect surfaces and project patterns onto them in real-time. Perfect for interactive installations, artistic projections, and AR experiences.

## Features

- **Real-time Surface Detection**: Automatically detects horizontal and vertical planes using ARKit
- **Multiple Projection Patterns**:
  - Gradient (blue to pink)
  - Grid pattern
  - Checkerboard pattern
- **Interactive Controls**: Easy-to-use UI for toggling projections and switching patterns
- **AR Integration**: Leverages Apple's ARKit for precise plane tracking and detection
- **Optimized Rendering**: Uses SceneKit for smooth 3D rendering

## Requirements

- **iOS 16.0+**
- **Xcode 14.0+**
- **Swift 5.0+**
- **Device with ARKit support** (iPhone 6s or later, iPad Pro, iPad 2017 or later)
- **A9 chip or later**

## Installation

### Using Xcode

1. Clone this repository:
   ```bash
   git clone https://github.com/M-ikolaj/hello.git
   cd hello
   ```

2. Open the Xcode project:
   ```bash
   open ProjectionMappingApp/ProjectionMappingApp.xcodeproj
   ```

3. Select your development team in the Xcode project settings:
   - Click on the project in the navigator
   - Select the "Projection Mapping" target
   - Go to "Signing & Capabilities"
   - Select your team from the dropdown

4. Connect your iOS device (ARKit requires a physical device, simulator won't work)

5. Build and run the app (⌘R)

## Usage

### Getting Started

1. **Launch the App**: Open the app on your iOS device
2. **Grant Camera Permission**: Allow camera access when prompted (required for AR)
3. **Scan Environment**: Slowly move your device to scan the environment
4. **Detect Planes**: Green semi-transparent planes will appear on detected surfaces
5. **Start Projection**: Tap "Start Projection" to project patterns onto detected planes
6. **Change Patterns**: Use the segmented control to switch between patterns

### Controls

- **Pattern Selector**: Choose from Gradient, Grid, or Checkerboard patterns
- **Start/Stop Button**: Toggle projection on/off
- **Info Button**: View AR support status and help information

### Tips for Best Results

- **Good Lighting**: Ensure adequate lighting for better plane detection
- **Flat Surfaces**: Works best on flat, textured surfaces (tables, walls, floors)
- **Slow Movement**: Move the device slowly for better tracking
- **Multiple Angles**: View surfaces from different angles to improve detection
- **Distance**: Keep the device 0.5-3 meters from the surface

## Project Structure

```
ProjectionMappingApp/
├── ProjectionMappingApp.xcodeproj/    # Xcode project file
│   └── project.pbxproj
└── ProjectionMappingApp/
    ├── ProjectionMappingApp.swift     # App entry point
    ├── ContentView.swift              # Main SwiftUI view with controls
    ├── ARProjectionView.swift         # SwiftUI wrapper for AR view
    ├── ProjectionViewController.swift # ARKit logic and projection mapping
    ├── Info.plist                     # App configuration
    └── Assets.xcassets/               # Asset catalog
        ├── AppIcon.appiconset/
        └── AccentColor.colorset/
```

## Technical Details

### ARKit Integration

The app uses `ARWorldTrackingConfiguration` with:
- Horizontal and vertical plane detection
- Light estimation for realistic rendering
- Scene depth (on supported devices)

### Projection System

Patterns are dynamically generated using `UIGraphicsImageRenderer` and applied as textures to `SCNPlane` geometries that match the detected surface dimensions.

### Pattern Generation

- **Gradient**: Linear gradient using Core Graphics
- **Grid**: Procedurally generated grid lines
- **Checkerboard**: Alternating squares pattern

## Customization

### Adding New Patterns

To add a new projection pattern:

1. Add the pattern name to `mediaOptions` in `ContentView.swift:11`
2. Create a new case in `createMaterial(for:)` in `ProjectionViewController.swift:113`
3. Implement a new pattern generation method (e.g., `createYourPatternImage()`)

Example:
```swift
// In ContentView.swift
let mediaOptions = ["gradient", "grid", "checkerboard", "custom"]

// In ProjectionViewController.swift
case "custom":
    material.diffuse.contents = createCustomImage()

private func createCustomImage() -> UIImage {
    // Your pattern generation code here
}
```

### Adjusting Projection Opacity

Modify the transparency value in `ProjectionViewController.swift:128`:
```swift
material.transparency = 0.8  // Change to desired value (0.0 - 1.0)
```

### Changing Projection Offset

Adjust the z-position to prevent z-fighting in `ProjectionViewController.swift:91`:
```swift
projectionNode.position = SCNVector3(0, 0.001, 0)  // Adjust offset value
```

## Troubleshooting

### AR Not Working

- **Check Device Compatibility**: Ensure your device has an A9 chip or later
- **Camera Permission**: Verify camera permissions in Settings > Privacy > Camera
- **Lighting**: Try using the app in better lighting conditions

### Planes Not Detected

- **Surface Quality**: Use textured surfaces (avoid mirrors, glass, or uniform colors)
- **Movement**: Move the device slowly in a sweeping motion
- **Distance**: Keep appropriate distance from surfaces (0.5-3m)

### App Crashes on Launch

- **Check Permissions**: Ensure camera permission is granted
- **Device Support**: Verify ARKit is supported on your device
- **Restart**: Try restarting the app and your device

## Future Enhancements

Potential features for future versions:

- [ ] Video projection support
- [ ] Custom image/texture upload
- [ ] Animated patterns
- [ ] Multiple simultaneous projections with different patterns
- [ ] Save/load projection configurations
- [ ] Recording capability
- [ ] Social sharing features
- [ ] 3D object projection (not just planes)

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- Built with Apple's ARKit framework
- Uses SceneKit for 3D rendering
- SwiftUI for modern iOS interface

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

**Note**: This app requires a physical iOS device with ARKit support. The iOS Simulator does not support ARKit functionality.
