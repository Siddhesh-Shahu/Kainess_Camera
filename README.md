Vintage Film Camera App (SwiftUI)
This is a modern SwiftUI camera application that emulates the charm of vintage film cameras. It provides a live camera feed with various customizable effects, including film styles, light leaks, date stamps, and manual exposure controls, allowing users to capture unique and artistic photos.

✨ Features
Live Camera Preview: Seamless display of the real-time camera feed.

Multiple Film Styles: Apply different film-like looks to your photos:

Normal: Clean, balanced, and sharp DSLR-like processing.

Kodak: Warm tones, vibrant reds/yellows, and slightly higher contrast.

Fuji: Cooler tones, enhanced greens and blues, and softer contrast.

Light Leak Effect: Toggle and adjust the intensity of a classic light leak overlay.

Date Stamp: Add a customizable date and time overlay to your captured photos.

Manual Controls: Take full control over your exposure with adjustable ISO and shutter speed settings.

Photo Capture & Saving: Capture photos with applied effects and save them directly to your device's photo library.

Haptic Feedback: Provides tactile feedback for key interactions like snapping a photo.

Settings Panel: An intuitive frosted-glass sheet for easy adjustment of all effects and manual controls.

🛠️ Requirements
Xcode: Version 13.0 or later.

iOS: Target iOS 15.0 or later.

Swift: Version 5.5 or later.

Frameworks: SwiftUI, AVFoundation, CoreImage, Photos.

📱 Usage
Launch the App: The camera preview will appear immediately.

Capture Photos: Tap the large circular Shutter Button at the bottom center to take a photo.

Access Settings: Tap the Gear icon (⚙️) in the top-left corner to reveal the settings panel.

Apply Film Styles: Use the "Film Style" picker above the shutter button to select between "Normal", "Kodak", and "Fuji" looks.

Toggle Light Leak: In the top-right, tap the Sparkles icon (✨) to turn the light leak effect on or off. You can adjust its intensity in the settings panel.

Adjust Settings (from panel):

Light Leak: Toggle "Enable Light Leak" and use the "Intensity" slider.

Date Stamp: Toggle "Show Date & Time".

Manual Controls: Toggle "Manual Mode" to enable ISO and Shutter Speed sliders.

Gallery/Camera Switch: The photo.on.rectangle icon (🖼️) and camera.rotate.fill icon (🔄) are placeholders for future gallery access and camera switching functionality, respectively.

🏗️ Code Structure Highlights
ContentView.swift: The main SwiftUI view responsible for the camera interface, integrating the camera preview, controls, and settings panel.

SettingsPanel.swift: A SwiftUI view that presents a customizable sheet for all camera settings, including toggles and sliders.

SettingsSection.swift: A reusable SwiftUI component to create consistent section headers and backgrounds within the settings panel.

CameraModel.swift: An ObservableObject that manages the AVCaptureSession, handles photo capture (AVCapturePhotoCaptureDelegate), applies CoreImage filters for film styles, light leaks, and date stamps, and saves the final image to the Photos library.

UIImage Extension: Includes a utility function to correctly fix image orientation after capture.

Note: The CameraPreview view (responsible for rendering the AVCaptureVideoPreviewLayer) is referenced in ContentView but its implementation is not provided in this snippet. It typically uses AVCaptureVideoPreviewLayer within a UIViewRepresentable or NSViewRepresentable.

💡 Future Enhancements
Implement the gallery access button to view saved photos.

Add functionality to switch between front and back cameras.

Introduce more film styles and advanced filter options.

Implement focus and exposure point selection on the camera preview.

Add a timer for photo capture.

Allow customization of the date stamp font, color, and position.

Implement video recording capabilities.
