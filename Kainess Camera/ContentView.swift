import SwiftUI
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

// MARK: - ContentView: Main Camera UI
struct ContentView: View {
    // State variables for various camera settings
    @State private var isLightLeakOn = false
    @State private var lightLeakIntensity: Double = 0.5
    @State private var isDateStampOn = false
    @State private var selectedFilmStyle: String = "Normal" // Changed default to "Normal"
    @State private var isManualModeOn = false
    @State private var iso: Float = 100.0
    @State private var shutterSpeed: Double = 1/60
    @State private var showSettings = false
    
    // ObservedObject for managing camera session and photo capture logic
    @StateObject private var cameraModel = CameraModel()

    // Array of available film styles (simplified)
    let filmStyles = ["Normal", "Kodak", "Fuji"] // Removed "Retro"

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: Camera Preview
                // Displays the live camera feed
                CameraPreview(cameraModel: cameraModel)
                    .ignoresSafeArea() // Extends the preview to fill the screen

                // MARK: Top Controls Bar
                VStack {
                    HStack {
                        // Settings Button: Toggles the visibility of the settings panel
                        Button(action: { showSettings.toggle() }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle() // Circular background with frosted glass effect
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.8)
                                )
                        }

                        Spacer() // Pushes elements to the edges

                        // Removed the top film style indicator

                        // Light Leak Toggle Button
                        Button(action: { isLightLeakOn.toggle() }) {
                            // Changed to use 'sparkles' consistently, color indicates state
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(isLightLeakOn ? .yellow : .white) // Color changes based on state
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle() // Circular background with frosted glass effect
                                        .fill(.ultraThinMaterial)
                                        .opacity(0.8)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    Spacer() // Pushes bottom controls to the bottom

                    // MARK: Bottom Control Area
                    VStack(spacing: 0) {
                        // Film Style Picker: Dropdown selection for film styles
                        Picker("Film Style", selection: $selectedFilmStyle) {
                            ForEach(filmStyles, id: \.self) { style in
                                Text(style.uppercased())
                                    .tag(style)
                            }
                        }
                        .pickerStyle(.menu) // Displays as a dropdown menu
                        .foregroundColor(.white) // Text color for the picker
                        .background(
                            Capsule() // Capsule-shaped background with frosted glass effect
                                .fill(.ultraThinMaterial)
                                .opacity(0.8)
                        )
                        .padding(.horizontal, 40) // Match horizontal padding of main controls
                        .padding(.bottom, 20) // Spacing between picker and shutter button row

                        // Main Controls Row: Gallery, Shutter, and Camera Switch buttons
                        HStack(spacing: 0) {
                            // Left: Gallery/Last Photo Button (Placeholder for functionality)
                            Button(action: {}) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "photo.on.rectangle")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                    )
                            }

                            Spacer()

                            // Center: Shutter Button
                            Button(action: {
                                // Calls the camera model to capture a photo with current settings
                                cameraModel.capturePhoto(
                                    applyLightLeak: isLightLeakOn,
                                    lightLeakIntensity: CGFloat(lightLeakIntensity),
                                    applyDateStamp: isDateStampOn,
                                    filmStyle: selectedFilmStyle,
                                    manualMode: isManualModeOn,
                                    iso: iso,
                                    shutterSpeed: shutterSpeed
                                )
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 80, height: 80)

                                    Circle()
                                        .stroke(.black.opacity(0.1), lineWidth: 2) // Outer ring
                                        .frame(width: 80, height: 80)

                                    if cameraModel.isProcessing {
                                        // Shows a loading indicator when processing a photo
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                            .scaleEffect(1.2)
                                    } else {
                                        // Inner circle of the shutter button
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 70, height: 70)
                                    }
                                }
                            }
                            .disabled(cameraModel.isProcessing) // Disable during processing
                            .scaleEffect(cameraModel.isProcessing ? 0.95 : 1.0) // Subtle scaling animation
                            .animation(.easeInOut(duration: 0.1), value: cameraModel.isProcessing)

                            Spacer()

                            // Right: Switch Camera Button (Placeholder for functionality)
                            Button(action: {}) {
                                Image(systemName: "camera.rotate.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle() // Circular background with frosted glass effect
                                            .fill(.ultraThinMaterial)
                                            .opacity(0.8)
                                    )
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20) // Adjusts for safe area
                    }
                    .background(
                        // Gradient background for the bottom control area
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .black.opacity(0.3),
                                .black.opacity(0.6)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .bottom)
                    )
                }

                // MARK: Settings Sheet
                // Displays the settings panel when `showSettings` is true
                if showSettings {
                    Color.black.opacity(0.3) // Semi-transparent overlay
                        .ignoresSafeArea()
                        .onTapGesture { showSettings = false } // Dismisses settings on tap outside

                    VStack {
                        Spacer() // Pushes the settings panel to the bottom
                        SettingsPanel(
                            isLightLeakOn: $isLightLeakOn,
                            lightLeakIntensity: $lightLeakIntensity,
                            isDateStampOn: $isDateStampOn,
                            isManualModeOn: $isManualModeOn,
                            iso: $iso,
                            shutterSpeed: $shutterSpeed,
                            showSettings: $showSettings
                        )
                    }
                }
            }
        }
        .onAppear {
            // Configures the camera session when the view appears
            cameraModel.configure()
        }
    }
}

// MARK: - Settings Panel
// A SwiftUI View that presents various camera settings.
struct SettingsPanel: View {
    // Bindings to sync settings with ContentView's state
    @Binding var isLightLeakOn: Bool
    @Binding var lightLeakIntensity: Double
    @Binding var isDateStampOn: Bool
    @Binding var isManualModeOn: Bool
    @Binding var iso: Float
    @Binding var shutterSpeed: Double
    @Binding var showSettings: Bool // Binding to dismiss the panel

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle for the sheet
            RoundedRectangle(cornerRadius: 2.5)
                .fill(.white.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)

            // Scrollable content area for settings
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: Light Leak Section
                    SettingsSection(title: "Light Leak") {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Enable Light Leak")
                                    .foregroundColor(.primary)
                                Spacer()
                                Toggle("", isOn: $isLightLeakOn)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue)) // Styled toggle switch
                            }

                            // Light Leak Intensity Slider, visible only when enabled
                            if isLightLeakOn {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Intensity")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("\(Int(lightLeakIntensity * 100))%")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }

                                    Slider(value: $lightLeakIntensity, in: 0...1)
                                        .accentColor(.blue)
                                }
                            }
                        }
                    }

                    // MARK: Date Stamp Section
                    SettingsSection(title: "Date Stamp") {
                        HStack {
                            Text("Show Date & Time")
                                .foregroundColor(.primary)
                            Spacer()
                            Toggle("", isOn: $isDateStampOn)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                    }

                    // MARK: Manual Controls Section
                    SettingsSection(title: "Manual Controls") {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Manual Mode")
                                    .foregroundColor(.primary)
                                Spacer()
                                Toggle("", isOn: $isManualModeOn)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                            }

                            // Manual controls (ISO and Shutter Speed) visible only when manual mode is on
                            if isManualModeOn {
                                VStack(spacing: 16) {
                                    // ISO Control
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("ISO")
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("\(Int(iso))")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }

                                        Slider(value: $iso, in: 50...800, step: 50) // ISO slider with steps
                                            .accentColor(.blue)
                                    }

                                    // Shutter Speed Control
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("Shutter Speed")
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("1/\(Int(1/shutterSpeed))") // Displays shutter speed as a fraction
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                        }

                                        Slider(value: $shutterSpeed, in: 1/1000...1/10) // Shutter speed slider
                                            .accentColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial) // Frosted glass background for the panel
        )
        .padding(.horizontal, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity)) // Transition for appearing/disappearing
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showSettings) // Spring animation
    }
}

// MARK: - Settings Section Component
// A reusable component to structure settings within the panel.
struct SettingsSection<Content: View>: View {
    let title: String // Title of the section
    let content: Content // The content to be displayed in the section

    // Custom initializer to accept a ViewBuilder for content
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            content // Displays the content provided
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thickMaterial) // Slightly thicker frosted glass background
                .opacity(0.5)
        )
    }
}

// MARK: - Camera Model: Handles capture and processing
// An ObservableObject to manage the AVCaptureSession and photo processing.
class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    public let session = AVCaptureSession() // The core AVCaptureSession
    public var previewLayer: AVCaptureVideoPreviewLayer! // Layer for displaying camera preview
    private let output = AVCapturePhotoOutput() // Output for capturing still photos
    private let context = CIContext() // Core Image context for applying filters

    @Published var isProcessing = false // Published property to indicate photo processing state

    // Internal state variables for photo effects and manual controls
    private var applyLightLeak = false
    private var lightLeakIntensity: CGFloat = 0.5
    private var applyDateStamp = false
    private var filmStyle: String = "Normal" // Changed default to "Normal"
    private var manualMode: Bool = false
    private var iso: Float = 100.0
    private var shutterSpeed: Double = 1/60

    // Configures the AVCaptureSession
    func configure() {
        // Perform configuration on a background queue to avoid blocking the UI
        DispatchQueue.global(qos: .userInitiated).async {
            guard let device = AVCaptureDevice.default(for: .video), // Get default video capture device
                  let input = try? AVCaptureDeviceInput(device: device) else { return } // Create input from device

            self.session.beginConfiguration() // Start session configuration
            if self.session.canAddInput(input) { self.session.addInput(input) } // Add input if possible
            if self.session.canAddOutput(self.output) { self.session.addOutput(self.output) } // Add photo output if possible
            self.session.commitConfiguration() // Commit changes to the session
            self.session.startRunning() // Start the session
        }
    }

    // Initiates photo capture with the specified settings
    func capturePhoto(applyLightLeak: Bool, lightLeakIntensity: CGFloat, applyDateStamp: Bool, filmStyle: String, manualMode: Bool, iso: Float, shutterSpeed: Double) {
        guard !isProcessing else { return } // Prevent multiple captures while processing

        // Add haptic feedback for shutter press
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        // Set processing state and capture settings
        self.isProcessing = true
        self.applyLightLeak = applyLightLeak
        self.lightLeakIntensity = lightLeakIntensity
        self.applyDateStamp = applyDateStamp
        self.filmStyle = filmStyle
        self.manualMode = manualMode
        self.iso = iso
        self.shutterSpeed = shutterSpeed

        let settings = AVCapturePhotoSettings()
        // Apply manual exposure settings if manual mode is enabled
        if manualMode, let device = AVCaptureDevice.default(for: .video) {
            try? device.lockForConfiguration() // Lock device for configuration
            device.setExposureModeCustom(duration: CMTimeMakeWithSeconds(Float64(shutterSpeed), preferredTimescale: 1000), iso: iso, completionHandler: nil)
            device.unlockForConfiguration() // Unlock device
        }

        // Capture the photo
        output.capturePhoto(with: settings, delegate: self)
    }

    // MARK: AVCapturePhotoCaptureDelegate
    // Called when photo capture is finished
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            DispatchQueue.main.async { self.isProcessing = false } // Reset processing state on error
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let capturedImage = UIImage(data: imageData) else {
            DispatchQueue.main.async { self.isProcessing = false }
            return
        }

        // Fix image orientation
        let uiImage = capturedImage.fixedOrientation()

        // Process image on a background queue
        DispatchQueue.global(qos: .userInitiated).async {
            var finalImage = uiImage

            // Apply selected film style
            finalImage = self.applyFilmStyle(to: finalImage)

            // Apply light leak overlay if enabled
            if self.applyLightLeak {
                finalImage = self.applyLightLeakOverlay(to: finalImage, intensity: self.lightLeakIntensity)
            }

            // Apply date stamp overlay if enabled
            if self.applyDateStamp {
                finalImage = self.applyDateStampOverlay(to: finalImage)
            }

            // Request photo library authorization and save the image
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil) // Save image to photo album

                    // Success haptic feedback and reset processing state
                    DispatchQueue.main.async {
                        let successFeedback = UINotificationFeedbackGenerator()
                        successFeedback.notificationOccurred(.success)
                        self.isProcessing = false
                    }
                } else {
                    // Handle photo library access denied
                    print("Photo Library access denied.")
                    DispatchQueue.main.async {
                        let errorFeedback = UINotificationFeedbackGenerator()
                        errorFeedback.notificationOccurred(.error)
                        self.isProcessing = false
                    }
                }
            }
        }
    }

    // Applies a "DaVinci" aesthetic filter (retro look) - This function is no longer called as "Retro" mode is removed.
    // Kept for reference but is effectively unused in the current setup.
    private func applyDaVinciAesthetic(to image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        let filter = CIFilter.colorControls() // Color controls filter
        filter.inputImage = ciImage
        filter.saturation = 0.5
        filter.brightness = 0.05
        filter.contrast = 1.3

        guard let output = filter.outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else { return image }
        return UIImage(cgImage: cgImage)
    }

    // Applies selected film style to the image
    private func applyFilmStyle(to image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        var processedCIImage: CIImage = ciImage // Start with the original CIImage

        switch filmStyle {
        case "Kodak":
            // Kodak-like processing: Warm tones, vibrant reds/yellows, slightly higher contrast
            // Starting with CIPhotoEffectProcess for a filmic base, then adjusting colors.
            var currentImage = ciImage
            if let processFilter = CIFilter(name: "CIPhotoEffectProcess") {
                processFilter.setValue(currentImage, forKey: kCIInputImageKey)
                currentImage = processFilter.outputImage ?? currentImage
            }

            let colorControlsFilter = CIFilter(name: "CIColorControls")!
            colorControlsFilter.setValue(currentImage, forKey: kCIInputImageKey)
            colorControlsFilter.setValue(1.15, forKey: kCIInputContrastKey) // Boost contrast
            colorControlsFilter.setValue(1.2, forKey: kCIInputSaturationKey) // Increase saturation, especially reds/yellows
            colorControlsFilter.setValue(0.05, forKey: kCIInputBrightnessKey) // Slightly increase brightness
            processedCIImage = colorControlsFilter.outputImage ?? currentImage

            // Optional: Add a subtle warmth via CIColorTemperature
            let temperatureFilter = CIFilter(name: "CITemperatureAndTint")!
            temperatureFilter.setValue(processedCIImage, forKey: kCIInputImageKey)
            temperatureFilter.setValue(CIVector(x: 7500, y: 0), forKey: "inputNeutral") // Warmer temperature
            processedCIImage = temperatureFilter.outputImage ?? processedCIImage

        case "Fuji":
            // Fuji-like processing: Cooler tones, good greens and blues, softer contrast
            // Starting with CIPhotoEffectChrome for a filmic base, then adjusting colors.
            var currentImage = ciImage
            if let chromeFilter = CIFilter(name: "CIPhotoEffectChrome") {
                chromeFilter.setValue(currentImage, forKey: kCIInputImageKey)
                currentImage = chromeFilter.outputImage ?? currentImage
            }

            let colorControlsFilter = CIFilter(name: "CIColorControls")!
            colorControlsFilter.setValue(currentImage, forKey: kCIInputImageKey)
            colorControlsFilter.setValue(0.95, forKey: kCIInputContrastKey) // Slightly softer contrast
            colorControlsFilter.setValue(1.05, forKey: kCIInputSaturationKey) // Slightly boost overall saturation
            colorControlsFilter.setValue(-0.02, forKey: kCIInputBrightnessKey) // Slightly decrease brightness
            processedCIImage = colorControlsFilter.outputImage ?? currentImage

            // Emphasize cool tones
            let temperatureFilter = CIFilter(name: "CITemperatureAndTint")!
            temperatureFilter.setValue(processedCIImage, forKey: kCIInputImageKey)
            temperatureFilter.setValue(CIVector(x: 5500, y: 150), forKey: "inputNeutral") // Cooler tint, greenish tint
            processedCIImage = temperatureFilter.outputImage ?? processedCIImage

        case "Normal": // Mapped from "Default"
            // Normal / DSLR-like processing: Clean, balanced, sharp, natural look
            // 1. Color Controls (Contrast, Brightness, Saturation)
            let colorControlsFilter = CIFilter(name: "CIColorControls")!
            colorControlsFilter.setValue(processedCIImage, forKey: kCIInputImageKey)
            colorControlsFilter.setValue(1.05, forKey: kCIInputContrastKey)     // Moderate contrast boost
            colorControlsFilter.setValue(0.0, forKey: kCIInputBrightnessKey)  // Neutral brightness
            colorControlsFilter.setValue(1.0, forKey: kCIInputSaturationKey) // Natural saturation
            processedCIImage = colorControlsFilter.outputImage ?? processedCIImage

            // 2. Sharpen Luminance
            let sharpenFilter = CIFilter(name: "CISharpenLuminance")!
            sharpenFilter.setValue(processedCIImage, forKey: kCIInputImageKey)
            sharpenFilter.setValue(0.6, forKey: kCIInputSharpnessKey) // Slightly stronger sharpening for a crisp look
            processedCIImage = sharpenFilter.outputImage ?? processedCIImage

            // 3. Highlight and Shadow Adjust
            let highlightShadowAdjustFilter = CIFilter(name: "CIHighlightShadowAdjust")!
            highlightShadowAdjustFilter.setValue(processedCIImage, forKey: kCIInputImageKey)
            highlightShadowAdjustFilter.setValue(0.8, forKey: "inputHighlightAmount") // Better highlight recovery
            highlightShadowAdjustFilter.setValue(0.6, forKey: "inputShadowAmount")   // Subtle shadow enhancement
            processedCIImage = highlightShadowAdjustFilter.outputImage ?? processedCIImage
            
        default:
            // Fallback if somehow an unhandled style is selected, applies basic color controls.
            let colorControlsFilter = CIFilter(name: "CIColorControls")!
            colorControlsFilter.setValue(processedCIImage, forKey: kCIInputImageKey)
            colorControlsFilter.setValue(1.0, forKey: kCIInputContrastKey)
            colorControlsFilter.setValue(0.0, forKey: kCIInputBrightnessKey)
            colorControlsFilter.setValue(1.0, forKey: kCIInputSaturationKey)
            processedCIImage = colorControlsFilter.outputImage ?? processedCIImage
        }

        // Render the processed CIImage back to UIImage
        guard let cgImage = context.createCGImage(processedCIImage, from: processedCIImage.extent) else { return image }
        return UIImage(cgImage: cgImage)
    }

    // Applies a light leak overlay to the image
    private func applyLightLeakOverlay(to image: UIImage, intensity: CGFloat) -> UIImage {
        // Make sure you have an image named "lightLeak" in your asset catalog.
        guard let leakImage = UIImage(named: "lightLeak") else { return image }
        
        // Begin image context for drawing
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: .zero, size: image.size)) // Draw original image
        leakImage.draw(in: CGRect(origin: .zero, size: image.size), blendMode: .screen, alpha: intensity) // Draw light leak with screen blend mode and adjustable alpha
        
        // Get the new image from the context
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext() // End the context
        return newImage ?? image
    }

    // Applies a date stamp overlay to the image
    private func applyDateStampOverlay(to image: UIImage) -> UIImage {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm" // Date format
        let dateString = formatter.string(from: date)

        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(origin: .zero, size: image.size)) // Draw original image
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right // Align date stamp to the right

        // Attributes for the date stamp text (font, color, stroke)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 40, weight: .medium),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -2.0 // Creates an outline effect
        ]

        let string = NSString(string: dateString)
        // Draw the date string at a specific position
        string.draw(in: CGRect(x: image.size.width - 400, y: image.size.height - 60, width: 380, height: 50), withAttributes: attrs)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image
    }
}

// MARK: - UIImage Extension to Fix Orientation
// Extension to UIImage to correct image orientation issues that can arise from camera capture.
extension UIImage {
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self // No rotation needed if already in upright orientation
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size)) // Redraws the image in the correct orientation
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? self
    }
}

// MARK: - CameraPreview: UIViewRepresentable for live camera preview
// A UIViewRepresentable wrapper to integrate AVCaptureVideoPreviewLayer into SwiftUI.
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraModel: CameraModel // ObservedObject to access the camera session

    func makeUIView(context: Context) -> UIView {
        let view = UIView() // Create a UIView to host the preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraModel.session) // Create preview layer with the camera session
        previewLayer.videoGravity = .resizeAspectFill // Fills the layer bounds while maintaining aspect ratio
        previewLayer.frame = UIScreen.main.bounds // Set frame to screen bounds

        // Fix preview orientation to portrait
        if let connection = previewLayer.connection, connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }

        view.layer.addSublayer(previewLayer) // Add the preview layer to the view's layer
        cameraModel.previewLayer = previewLayer // Store a reference to the preview layer in the model
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed for the UIView itself, as the session is managed by CameraModel
    }
}
