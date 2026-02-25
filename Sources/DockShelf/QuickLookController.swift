import Cocoa
import QuickLookUI

class QuickLookController: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    static let shared = QuickLookController()

    private var previewItem: URL?
    private var panel: QLPreviewPanel?

    override init() {
        super.init()
    }

    func previewFile(at url: URL) {
        self.previewItem = url

        if let panel = QLPreviewPanel.shared() {
            self.panel = panel
            // QLPreviewPanel.shared() returns a singleton, but we need to ensure it's configured correctly.
            // The panel might be reused by other parts of the system or app, but here we take control.

            // We need to set the delegate and data source.
            // Note: QLPreviewPanel relies on the responder chain.
            // However, setting it directly here is a common pattern for simple usage.
            panel.dataSource = self
            panel.delegate = self

            // Reload data to ensure the new item is displayed
            panel.reloadData()

            // Show the panel if not already visible
            if !panel.isVisible {
                panel.makeKeyAndOrderFront(nil)
            }

            // Force the panel to update its content immediately
            panel.refreshCurrentPreviewItem()
        }
    }

    // MARK: - QLPreviewPanelDataSource

    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return previewItem != nil ? 1 : 0
    }

    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return previewItem as NSURL?
    }

    // MARK: - QLPreviewPanelDelegate

    func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        // Return false to let the default behavior handle events
        return false
    }
}
