import AppKit
import Combine

class DockPositionManager {
    private weak var window: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    
    // Default shelf length (width for bottom dock, height for side dock)
    private let shelfLength: CGFloat = 400 
    
    init(window: NSWindow) {
        self.window = window
        setupObservers()
        // Wait a beat for layout to settle
        DispatchQueue.main.async {
            self.updateWindowPosition()
        }
    }
    
    private func setupObservers() {
        // Observe screen parameter changes (resolution, dock position/size changes)
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                self?.updateWindowPosition()
            }
            .store(in: &cancellables)
            
        // Observe active application changes to re-check dock visibility if needed
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didActivateApplicationNotification)
            .sink { [weak self] _ in
                self?.updateWindowPosition()
            }
            .store(in: &cancellables)
            
        // Observe active space changes (Dock might move to the active screen)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
            .sink { [weak self] _ in
                self?.updateWindowPosition()
            }
            .store(in: &cancellables)
    }
    
    func updateWindowPosition() {
        guard let window = window else { return }
        
        var targetScreen: NSScreen?
        var dockLocation: DockLocation = .hidden
        var dockThickness: CGFloat = 0
        
        // Threshold to consider Dock visible (reserved space > 5px)
        let dockThreshold: CGFloat = 5
        
        for screen in NSScreen.screens {
            let full = screen.frame
            let visible = screen.visibleFrame
            
            // Calculate potential dock thicknesses
            let bottomDiff = visible.minY - full.minY
            let leftDiff = visible.minX - full.minX
            let rightDiff = full.maxX - visible.maxX
            
            // Check Bottom
            if bottomDiff > dockThreshold {
                targetScreen = screen
                dockLocation = .bottom
                dockThickness = bottomDiff
                break
            }
            
            // Check Left
            if leftDiff > dockThreshold {
                targetScreen = screen
                dockLocation = .left
                dockThickness = leftDiff
                break
            }
            
            // Check Right
            if rightDiff > dockThreshold {
                targetScreen = screen
                dockLocation = .right
                dockThickness = rightDiff
                break
            }
        }
        
        if let screen = targetScreen, dockLocation != .hidden {
            var newFrame = window.frame
            let full = screen.frame
            
            switch dockLocation {
            case .bottom:
                // Shelf matches Dock height (thickness)
                let height = dockThickness
                let width = shelfLength
                
                // Position: Bottom-Right corner aligned with Dock
                // X: Right edge of screen - width
                // Y: Bottom of screen (full.minY)
                let x = full.maxX - width
                let y = full.minY 
                
                newFrame = NSRect(x: x, y: y, width: width, height: height)
                
            case .left:
                // Shelf matches Dock width (thickness)
                let width = dockThickness
                let height = shelfLength
                
                // Position: Bottom-Left corner aligned with Dock
                // X: Left edge of screen
                // Y: Bottom of screen (full.minY)
                let x = full.minX
                let y = full.minY
                
                newFrame = NSRect(x: x, y: y, width: width, height: height)
                
            case .right:
                // Shelf matches Dock width (thickness)
                let width = dockThickness
                let height = shelfLength
                
                // Position: Bottom-Right corner aligned with Dock
                // X: Right edge of screen - width
                // Y: Bottom of screen
                let x = full.maxX - width
                let y = full.minY
                
                newFrame = NSRect(x: x, y: y, width: width, height: height)
                
            case .hidden:
                break
            }
            
            window.setFrame(newFrame, display: true)
            if !window.isVisible {
                window.orderFront(nil)
            }
            
        } else {
            // Dock is hidden or auto-hidden (size < threshold)
            window.orderOut(nil)
        }
    }
    
    enum DockLocation {
        case bottom, left, right, hidden
    }
}
