import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ShelfView: View {
    @ObservedObject var model: ShelfModel
    
    // We use a GeometryReader to determine if we should lay out horizontally or vertically.
    // If width > height -> Horizontal Strip (Bottom Dock)
    // If height > width -> Vertical Strip (Side Dock)
    
    var body: some View {
        GeometryReader { geometry in
            let isHorizontal = geometry.size.width > geometry.size.height
            
            if isHorizontal {
                // Horizontal Layout (Bottom Dock)
                HStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 10) {
                            ForEach(model.items) { item in
                                ShelfItemView(item: item, onRemove: {
                                    Task {
                                        await model.removeItem(id: item.id)
                                    }
                                })
                                    .frame(width: geometry.size.height - 10, height: geometry.size.height - 10) // Square items fitting height
                                    .onTapGesture(count: 2) {
                                        NSWorkspace.shared.open(item.url)
                                    }
                                    .onDrag {
                                        // Use contentsOf: to create a file item provider, which handles IPC/Sandboxing correctly
                                        let itemProvider: NSItemProvider
                                        if let provider = NSItemProvider(contentsOf: item.url) {
                                            itemProvider = provider
                                        } else {
                                            // Fallback if creating provider fails
                                            itemProvider = NSItemProvider(object: item.url as NSURL)
                                        }
                                        itemProvider.suggestedName = item.url.lastPathComponent
                                        return itemProvider
                                    }
                                    .contextMenu {
                                        Button("Open") {
                                            NSWorkspace.shared.open(item.url)
                                        }
                                        Button("Reveal in Finder") {
                                            NSWorkspace.shared.activateFileViewerSelecting([item.url])
                                        }
                                        Divider()
                                        Button("Remove") {
                                            // Perform removal without animation inside the button action to prevent layout crashes
                                            Task {
                                                // Add a small delay to allow context menu to dismiss
                                                try? await Task.sleep(nanoseconds: 200_000_000)
                                                await model.removeItem(id: item.id)
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    // Enable drop on the entire scroll area
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers, _ in
                        return handleDrop(providers: providers)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    // Clear Button
                    Button(action: {
                        withAnimation {
                            model.clearAll()
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                }
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
            } else {
                // Vertical Layout (Side Dock)
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(model.items) { item in
                                ShelfItemView(item: item, onRemove: {
                                    Task {
                                        await model.removeItem(id: item.id)
                                    }
                                })
                                    .frame(width: geometry.size.width - 10, height: geometry.size.width - 10) // Square items fitting width
                                    .onTapGesture(count: 2) {
                                        NSWorkspace.shared.open(item.url)
                                    }
                                    .onDrag {
                                        // Use contentsOf: to create a file item provider, which handles IPC/Sandboxing correctly
                                        let itemProvider: NSItemProvider
                                        if let provider = NSItemProvider(contentsOf: item.url) {
                                            itemProvider = provider
                                        } else {
                                            // Fallback if creating provider fails
                                            itemProvider = NSItemProvider(object: item.url as NSURL)
                                        }
                                        itemProvider.suggestedName = item.url.lastPathComponent
                                        return itemProvider
                                    }
                                    .contextMenu {
                                        Button("Open") {
                                            NSWorkspace.shared.open(item.url)
                                        }
                                        Button("Reveal in Finder") {
                                            NSWorkspace.shared.activateFileViewerSelecting([item.url])
                                        }
                                        Divider()
                                        Button("Remove") {
                                            // Perform removal without animation inside the button action to prevent layout crashes
                                            Task {
                                                // Add a small delay to allow context menu to dismiss
                                                try? await Task.sleep(nanoseconds: 200_000_000)
                                                await model.removeItem(id: item.id)
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    // Enable drop
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers, _ in
                        return handleDrop(providers: providers)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    Button(action: {
                        withAnimation {
                            model.clearAll()
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                }
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url = url {
                        DispatchQueue.main.async {
                            if url.isFileURL {
                                self.model.addItem(url: url)
                            }
                        }
                    }
                }
            }
        }
        return true
    }
}

struct ShelfItemView: View {
    let item: ShelfItem
    var onRemove: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Image(nsImage: item.displayImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .padding(4)
            .background(Color.black.opacity(0.1))
            .cornerRadius(6)
            // Add a helpful tooltip
            .help(item.url.lastPathComponent)
            // Force Touch for Quick Look
            .overlay(
                ForceClickable(onForceClick: {
                    QuickLookController.shared.previewFile(at: item.url)
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            )

            if isHovering {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .background(Circle().fill(Color.white))
                }
                .buttonStyle(.plain)
                .offset(x: 6, y: -6)
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}
