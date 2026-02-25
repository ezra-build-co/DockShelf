import Foundation
import Combine
import AppKit

class ScreenshotWatcher {
    private var model: ShelfModel
    private var query: NSMetadataQuery?
    private var isStarted = false

    // Track seen items to avoid processing old screenshots on startup
    private var seenItems: Set<String> = []
    
    init(model: ShelfModel) {
        self.model = model
    }
    
    func start() {
        guard !isStarted else { return }
        isStarted = true

        let query = NSMetadataQuery()
        self.query = query

        // Use predicate string format for kMDItemIsScreenCapture
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture == 1")
        query.searchScopes = [NSMetadataQueryUserHomeScope]

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryDidUpdate(_:)),
            name: .NSMetadataQueryDidUpdate,
            object: query
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryDidFinishGathering(_:)),
            name: .NSMetadataQueryDidFinishGathering,
            object: query
        )

        // Start the query on the main thread (required for NSMetadataQuery)
        DispatchQueue.main.async {
            query.start()
        }

        print("Started watching for screenshots via Spotlight metadata.")
    }
    
    func stop() {
        guard isStarted, let query = query else { return }

        query.stop()
        NotificationCenter.default.removeObserver(self)
        self.query = nil
        isStarted = false
    }
    
    @objc private func queryDidFinishGathering(_ notification: Notification) {
        guard let query = notification.object as? NSMetadataQuery else { return }
        
        query.disableUpdates()
        
        // Mark existing screenshots as "seen" so we don't re-add them
        for i in 0..<query.resultCount {
            if let item = query.result(at: i) as? NSMetadataItem,
               let path = item.value(forAttribute: NSMetadataItemPathKey) as? String {
                seenItems.insert(path)
            }
        }
        
        query.enableUpdates()
        print("Initial screenshot scan complete. Watching for new items...")
    }
    
    @objc private func queryDidUpdate(_ notification: Notification) {
        guard let query = notification.object as? NSMetadataQuery else { return }

        query.disableUpdates()
        
        // Correct key: NSMetadataQueryUpdateAddedItemsKey
        if let userInfo = notification.userInfo,
           let addedItems = userInfo[NSMetadataQueryUpdateAddedItemsKey] as? [NSMetadataItem] {
            
            for item in addedItems {
                if let path = item.value(forAttribute: NSMetadataItemPathKey) as? String {
                    // Check if we've already seen this path (e.g. from initial scan or previous update)
                    if !seenItems.contains(path) {
                        seenItems.insert(path)
                        
                        let url = URL(fileURLWithPath: path)
                        
                        print("New screenshot detected: \(path)")
                        // Ensure model update happens on main actor
                        DispatchQueue.main.async {
                            self.model.addItem(url: url)
                        }
                    }
                }
            }
        }

        query.enableUpdates()
    }
}
