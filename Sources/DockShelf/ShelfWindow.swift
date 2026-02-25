import AppKit
import SwiftUI

class ShelfWindow: NSPanel {
    init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, 
                   styleMask: [.nonactivatingPanel, .borderless, .fullSizeContentView], 
                   backing: backing, 
                   defer: flag)
        
        self.isFloatingPanel = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false // Let SwiftUI handle shadow or visual effect
        self.isMovableByWindowBackground = false
        self.hidesOnDeactivate = false
        
        // Ensure it doesn't become key easily, but allows interaction
        self.becomesKeyOnlyIfNeeded = true
    }
    
    // Allow the window to be key for interaction (e.g. deleting items) but not steal focus aggressively
    override var canBecomeKey: Bool {
        return true 
    }
    
    override var canBecomeMain: Bool {
        return false
    }
}
