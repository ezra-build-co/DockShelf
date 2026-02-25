import Foundation
import Combine
import AppKit
import Darwin // For O_EVTONLY and open/close

class ScreenshotWatcher {
    private var model: ShelfModel
    private var source: DispatchSourceFileSystemObject?
    private var directoryFileDescriptor: CInt = -1
    private var lastScanDate: Date = Date()
    private let queue = DispatchQueue(label: "com.dockshelf.screenshotwatcher")
    
    init(model: ShelfModel) {
        self.model = model
    }
    
    func start() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // Determine screenshot location (default to Desktop)
            let path = self.getScreenshotLocation()
            let url = URL(fileURLWithPath: path)
            
            // Open the directory
            // We need to use low-level C API to open for monitoring
            // path.withCString creates a temporary pointer valid only within the closure
            let fd = path.withCString { ptr -> CInt in
                return open(ptr, O_EVTONLY)
            }
            
            self.directoryFileDescriptor = fd
            
            guard self.directoryFileDescriptor != -1 else {
                print("Error: Could not open screenshot directory for monitoring: \(path)")
                return
            }
            
            // Create the source
            let src = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: self.directoryFileDescriptor,
                eventMask: .write,
                queue: self.queue
            )
            self.source = src
            
            src.setEventHandler { [weak self] in
                self?.checkForNewScreenshots(in: url)
            }
            
            src.setCancelHandler { [weak self] in
                guard let self = self else { return }
                close(self.directoryFileDescriptor)
            }
            
            src.resume()
            print("Started watching for screenshots in: \(path)")
        }
    }
    
    func stop() {
        source?.cancel()
        source = nil
    }
    
    private func getScreenshotLocation() -> String {
        // Read user default for screencapture location
        let task = Process()
        task.launchPath = "/usr/bin/defaults"
        task.arguments = ["read", "com.apple.screencapture", "location"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        // Handle potential errors (e.g. key not found) by ignoring stderr
        let errorPipe = Pipe()
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !output.isEmpty {
                // Expand tilde if present (though defaults usually returns full path)
                let expandedPath = NSString(string: output).expandingTildeInPath
                if FileManager.default.fileExists(atPath: expandedPath) {
                    return expandedPath
                }
            }
        } catch {
            print("Error reading defaults: \(error)")
        }
        
        // Fallback to Desktop
        let paths = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
        return paths.first ?? "/tmp"
    }
    
    private func checkForNewScreenshots(in directory: URL) {
        let fileManager = FileManager.default
        let now = Date()
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.creationDateKey, .isRegularFileKey],
                options: .skipsHiddenFiles
            )
            
            for url in fileURLs {
                let resources = try url.resourceValues(forKeys: [.creationDateKey, .isRegularFileKey])
                
                guard let isFile = resources.isRegularFile, isFile,
                      let creationDate = resources.creationDate else { continue }
                
                // Check if created since last scan
                if creationDate > lastScanDate {
                    let filename = url.lastPathComponent
                    // Check for standard macOS screenshot naming
                    if (filename.contains("Screen Shot") || filename.contains("Screenshot")) &&
                       (filename.hasSuffix(".png") || filename.hasSuffix(".jpg") || filename.hasSuffix(".jpeg")) {
                        
                        print("New screenshot detected: \(filename)")
                        
                        DispatchQueue.main.async {
                            self.model.addItem(url: url)
                        }
                    }
                }
            }
            
            lastScanDate = now
            
        } catch {
            print("Error scanning for screenshots: \(error)")
        }
    }
}
