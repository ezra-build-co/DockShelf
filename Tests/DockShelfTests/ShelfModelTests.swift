import XCTest
@testable import DockShelf

final class ShelfModelTests: XCTestCase {
    
    var model: ShelfModel!
    
    override func setUp() {
        super.setUp()
        // Reset UserDefaults for testing
        UserDefaults.standard.removeObject(forKey: "DockShelfItems")
        model = ShelfModel()
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "DockShelfItems")
        model = nil
        super.tearDown()
    }
    
    func testAddItem() {
        let url = URL(fileURLWithPath: "/tmp/testfile.txt")
        model.addItem(url: url)
        
        XCTAssertEqual(model.items.count, 1)
        XCTAssertEqual(model.items.first?.url.path, url.path)
    }
    
    func testPersistence() {
        let url = URL(fileURLWithPath: "/tmp/persisted.txt")
        model.addItem(url: url)
        
        // Simulate app restart by creating a new model instance
        let newModel = ShelfModel()
        XCTAssertEqual(newModel.items.count, 1)
        XCTAssertEqual(newModel.items.first?.url.path, url.path)
    }
    
    func testRemoveItem() {
        let url = URL(fileURLWithPath: "/tmp/remove.txt")
        model.addItem(url: url)
        
        guard let item = model.items.first else {
            XCTFail("Item should exist")
            return
        }
        
        model.removeItem(id: item.id)
        XCTAssertEqual(model.items.count, 0)
    }
    
    func testClearAll() {
        model.addItem(url: URL(fileURLWithPath: "/tmp/1.txt"))
        model.addItem(url: URL(fileURLWithPath: "/tmp/2.txt"))
        
        XCTAssertEqual(model.items.count, 2)
        
        model.clearAll()
        XCTAssertEqual(model.items.count, 0)
    }
}
