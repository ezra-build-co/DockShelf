import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: ShelfWindow!
    var model: ShelfModel!
    var dockManager: DockPositionManager!
    var screenshotWatcher: ScreenshotWatcher!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the shared model
        model = ShelfModel()
        
        // Start watching for screenshots
        screenshotWatcher = ScreenshotWatcher(model: model)
        screenshotWatcher.start()
        
        // Create the SwiftUI view
        let shelfView = ShelfView(model: model)
        
        // Create the window
        // Initial frame is arbitrary, will be updated by DockPositionManager
        window = ShelfWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            backing: .buffered,
            defer: false
        )
        
        // Set up content controller
        let hostingController = NSHostingController(rootView: shelfView)
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        window.contentViewController = hostingController
        
        // Initialize Dock Manager to position the window
        dockManager = DockPositionManager(window: window)
        
        // Ensure window behavior
        window.makeKeyAndOrderFront(nil)
        
        // Set activation policy to accessory (hide from Dock/Cmd-Tab) or regular
        // For a utility like this, accessory is often preferred.
        NSApp.setActivationPolicy(.accessory)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Insert code here to tear down your application
        screenshotWatcher?.stop()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Prevent utility app from terminating if the window is hidden or closed (e.g. during Dock hiding)
        return false
    }
}
