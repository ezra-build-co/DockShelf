import SwiftUI
import AppKit

struct ForceClickable: NSViewRepresentable {
    var onForceClick: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        // Transparent view to overlay
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor

        let recognizer = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.clicked(_:)))
        recognizer.pressureConfiguration = NSPressureConfiguration(pressureBehavior: .primaryDeepClick)
        // Allow normal clicks to pass through to underlying views (for double-click open, etc.)
        recognizer.delaysPrimaryMouseButtonEvents = false
        view.addGestureRecognizer(recognizer)

        // This is important: The view needs to accept mouse events for the recognizer to work,
        // but we want clicks to pass through if they aren't force clicks.
        // However, NSView by default accepts clicks.
        // Let's ensure the view can become first responder if needed.
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onForceClick: onForceClick)
    }

    class Coordinator: NSObject {
        var onForceClick: () -> Void

        init(onForceClick: @escaping () -> Void) {
            self.onForceClick = onForceClick
        }

        @objc func clicked(_ sender: NSClickGestureRecognizer) {
            if sender.state == .ended {
                onForceClick()
            }
        }
    }
}
