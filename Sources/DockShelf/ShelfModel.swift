import Foundation
import Combine
import AppKit
import QuickLookThumbnailing

struct ShelfItem: Identifiable, Hashable {
    let id: UUID
    let url: URL
    var thumbnail: NSImage?
    
    init(url: URL, id: UUID = UUID()) {
        self.url = url
        self.id = id
        self.thumbnail = nil
    }
    
    // Conformance to Hashable for SwiftUI Lists
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ShelfItem, rhs: ShelfItem) -> Bool {
        return lhs.id == rhs.id
    }

    var displayImage: NSImage {
        if let thumb = thumbnail {
            return thumb
        }
        return NSWorkspace.shared.icon(forFile: url.path)
    }
}

@MainActor
class ShelfModel: ObservableObject {
    @Published var items: [ShelfItem] = []
    
    private let storageKey = "DockShelfItems"
    
    init() {
        loadItems()
    }
    
    func addItem(url: URL) {
        // Prevent duplicates based on URL
        if !items.contains(where: { $0.url == url }) {
            let newItem = ShelfItem(url: url)
            items.append(newItem)
            saveItems()
            generateThumbnail(for: newItem)
        }
    }
    
    func removeItem(id: UUID) {
        // Use filter to create a new array, ensuring clean state update
        items = items.filter { $0.id != id }
        saveItems()
    }
    
    func clearAll() {
        items.removeAll()
        saveItems()
    }
    
    private func saveItems() {
        let paths = items.map { $0.url.path }
        UserDefaults.standard.set(paths, forKey: storageKey)
    }
    
    private func loadItems() {
        guard let paths = UserDefaults.standard.stringArray(forKey: storageKey) else { return }
        
        self.items = paths.compactMap { path in
            let url = URL(fileURLWithPath: path)
            // Check if file still exists? User said it's okay if it's broken, 
            // but maybe we should filter out non-existing ones on load?
            // "If you delete the original file from Finder, the shelf item will become broken or disappear."
            // Let's keep them and maybe show a broken icon, or just let them disappear if we want to be "smart".
            // For now, let's load them all.
            return ShelfItem(url: url)
        }
        
        // Generate thumbnails for loaded items
        for item in self.items {
            generateThumbnail(for: item)
        }
    }
    
    private func generateThumbnail(for item: ShelfItem) {
        // Use a larger size for high-quality previews
        let size = CGSize(width: 512, height: 512)
        // Ensure we access NSScreen on the main thread
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        
        // Request ONLY thumbnail (preview) representation to force content preview.
        // If we include .icon, QL often returns a file icon with a tiny preview inside, which the user dislikes for images.
        let request = QLThumbnailGenerator.Request(fileAt: item.url, 
                                                   size: size, 
                                                   scale: scale, 
                                                   representationTypes: [.thumbnail])
        
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { [weak self] (thumbnail, error) in
            guard let self = self else { return }
            
            // Ensure UI updates happen on main actor
            Task { @MainActor in
                if let thumbnail = thumbnail {
                    // Check if item still exists before updating
                    if let index = self.items.firstIndex(where: { $0.id == item.id }) {
                        self.items[index].thumbnail = thumbnail.nsImage
                    }
                } else {
                    // If thumbnail generation fails (e.g. no preview available), we fall back to the default icon in displayImage.
                    if let error = error {
                        print("Thumbnail generation skipped/failed for \(item.url.lastPathComponent): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
