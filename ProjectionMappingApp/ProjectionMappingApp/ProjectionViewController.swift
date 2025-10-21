import UIKit
import ARKit
import SceneKit

class ProjectionViewController: UIViewController, ARSCNViewDelegate {

    // MARK: - Properties
    private var sceneView: ARSCNView!
    private var configuration = ARWorldTrackingConfiguration()
    private var detectedPlanes: [UUID: SCNNode] = [:]
    private var projectionNodes: [SCNNode] = []
    private var currentMedia: String = "gradient"
    private var isProjecting: Bool = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARScene()
        configureAR()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - AR Setup
    private func setupARScene() {
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.delegate = self
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.automaticallyUpdatesLighting = true

        // Enable debug options (optional)
        #if DEBUG
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        #endif

        view.addSubview(sceneView)
    }

    private func configureAR() {
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isLightEstimationEnabled = true

        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics.insert(.sceneDepth)
        }
    }

    private func startARSession() {
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - Public Methods
    func updateProjection(isProjecting: Bool, media: String) {
        self.isProjecting = isProjecting
        self.currentMedia = media

        if isProjecting {
            enableProjection()
        } else {
            disableProjection()
        }
    }

    // MARK: - Projection Methods
    private func enableProjection() {
        // Project onto all detected planes
        for (planeId, planeNode) in detectedPlanes {
            if !projectionNodes.contains(where: { $0.name == planeId.uuidString }) {
                addProjection(to: planeNode, planeId: planeId)
            }
        }
    }

    private func disableProjection() {
        // Remove all projection nodes
        for node in projectionNodes {
            node.removeFromParentNode()
        }
        projectionNodes.removeAll()
    }

    private func addProjection(to planeNode: SCNNode, planeId: UUID) {
        guard let planeGeometry = planeNode.geometry as? SCNPlane else { return }

        // Create a new plane for projection
        let projectionPlane = SCNPlane(width: planeGeometry.width, height: planeGeometry.height)

        // Create material with selected pattern
        let material = createMaterial(for: currentMedia)
        projectionPlane.materials = [material]

        // Create node
        let projectionNode = SCNNode(geometry: projectionPlane)
        projectionNode.name = planeId.uuidString
        projectionNode.position = SCNVector3(0, 0.001, 0) // Slightly above the plane to prevent z-fighting

        // Add to plane node
        planeNode.addChildNode(projectionNode)
        projectionNodes.append(projectionNode)
    }

    private func createMaterial(for mediaType: String) -> SCNMaterial {
        let material = SCNMaterial()

        switch mediaType {
        case "gradient":
            // Create a gradient texture
            material.diffuse.contents = createGradientImage()

        case "grid":
            // Create a grid pattern
            material.diffuse.contents = createGridImage()

        case "checkerboard":
            // Create a checkerboard pattern
            material.diffuse.contents = createCheckerboardImage()

        default:
            material.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
        }

        material.isDoubleSided = true
        material.transparency = 0.8
        material.lightingModel = .physicallyBased

        return material
    }

    // MARK: - Pattern Generation
    private func createGradientImage() -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let colors = [UIColor.blue.cgColor, UIColor.purple.cgColor, UIColor.pink.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: colors as CFArray,
                                     locations: [0.0, 0.5, 1.0])!

            context.cgContext.drawLinearGradient(gradient,
                                                start: CGPoint(x: 0, y: 0),
                                                end: CGPoint(x: size.width, y: size.height),
                                                options: [])
        }
    }

    private func createGridImage() -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: size))

            context.cgContext.setStrokeColor(UIColor.blue.cgColor)
            context.cgContext.setLineWidth(2)

            let gridSize: CGFloat = 64

            // Vertical lines
            for i in stride(from: 0, through: size.width, by: gridSize) {
                context.cgContext.move(to: CGPoint(x: i, y: 0))
                context.cgContext.addLine(to: CGPoint(x: i, y: size.height))
            }

            // Horizontal lines
            for i in stride(from: 0, through: size.height, by: gridSize) {
                context.cgContext.move(to: CGPoint(x: 0, y: i))
                context.cgContext.addLine(to: CGPoint(x: size.width, y: i))
            }

            context.cgContext.strokePath()
        }
    }

    private func createCheckerboardImage() -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let squareSize: CGFloat = 64

            for row in 0..<Int(size.height / squareSize) {
                for col in 0..<Int(size.width / squareSize) {
                    if (row + col) % 2 == 0 {
                        context.cgContext.setFillColor(UIColor.black.cgColor)
                    } else {
                        context.cgContext.setFillColor(UIColor.white.cgColor)
                    }

                    let rect = CGRect(x: CGFloat(col) * squareSize,
                                    y: CGFloat(row) * squareSize,
                                    width: squareSize,
                                    height: squareSize)
                    context.cgContext.fill(rect)
                }
            }
        }
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        DispatchQueue.main.async {
            self.createPlaneNode(for: planeAnchor, node: node)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        DispatchQueue.main.async {
            self.updatePlaneNode(for: planeAnchor, node: node)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        DispatchQueue.main.async {
            self.removePlaneNode(for: planeAnchor)
        }
    }

    // MARK: - Plane Management
    private func createPlaneNode(for planeAnchor: ARPlaneAnchor, node: SCNNode) {
        let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width),
                           height: CGFloat(planeAnchor.planeExtent.height))

        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.opacity = 0.25

        // Create semi-transparent visualization material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green.withAlphaComponent(0.3)
        material.isDoubleSided = true
        plane.materials = [material]

        node.addChildNode(planeNode)
        detectedPlanes[planeAnchor.identifier] = planeNode

        // If projection is enabled, add projection to this plane
        if isProjecting {
            addProjection(to: planeNode, planeId: planeAnchor.identifier)
        }
    }

    private func updatePlaneNode(for planeAnchor: ARPlaneAnchor, node: SCNNode) {
        guard let planeNode = detectedPlanes[planeAnchor.identifier],
              let plane = planeNode.geometry as? SCNPlane else { return }

        // Update plane dimensions
        plane.width = CGFloat(planeAnchor.planeExtent.width)
        plane.height = CGFloat(planeAnchor.planeExtent.height)
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)

        // Update projection if active
        if isProjecting {
            // Remove old projection
            if let projectionNode = planeNode.childNodes.first(where: { $0.name == planeAnchor.identifier.uuidString }) {
                projectionNode.removeFromParentNode()
                projectionNodes.removeAll(where: { $0.name == planeAnchor.identifier.uuidString })
            }

            // Add updated projection
            addProjection(to: planeNode, planeId: planeAnchor.identifier)
        }
    }

    private func removePlaneNode(for planeAnchor: ARPlaneAnchor) {
        detectedPlanes[planeAnchor.identifier]?.removeFromParentNode()
        detectedPlanes.removeValue(forKey: planeAnchor.identifier)

        projectionNodes.removeAll(where: { $0.name == planeAnchor.identifier.uuidString })
    }
}
