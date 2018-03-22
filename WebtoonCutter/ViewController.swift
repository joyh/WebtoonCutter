import Cocoa
import CoreServices
import ImageIO

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var widthField: NSTextField!
    @IBOutlet weak var heightField: NSTextField!
    @IBOutlet weak var prefixField: NSTextField!
    @IBOutlet weak var sliceButton: NSButton!
    
    var sourceURLs = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sliceButton.isEnabled = false
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return sourceURLs.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeView(withIdentifier: tableColumn?.identifier ?? NSUserInterfaceItemIdentifier(rawValue: ""), owner: self) as? NSTableCellView
        cellView?.textField?.stringValue = "\(sourceURLs[row].path)"
        return cellView
    }

    @IBAction func addFolder(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.beginSheetModal(for: self.view.window!) { (res) in
            guard res.rawValue == 1 else { return }
            guard let dir = openPanel.url else { return }
            self.sourceURLs = self.allJPEGURLsInDirectory(dir)
            self.tableView.reloadData()
            self.sliceButton.isEnabled = true
            self.prefixField.stringValue = dir.lastPathComponent + "-"
        }
    }
    
    func allJPEGURLsInDirectory(_ dir: URL) -> [URL] {
        var results = [URL]()
        guard let paths = try? FileManager.default.contentsOfDirectory(atPath: dir.path) else { return results }
        for p in paths.sorted() {
            let url = URL(fileURLWithPath: p, relativeTo: dir)
            guard let uti = (try? url.resourceValues(forKeys: [.typeIdentifierKey]))?.allValues[.typeIdentifierKey] as? String else { continue }
            guard uti == kUTTypeJPEG as String else { continue }
            results.append(url)
        }
        return results
    }
    
    @IBAction func handleSliceClick(_ sender: Any) {
        let width = widthField.integerValue
        let height = heightField.integerValue
        let slicer = ImageSlicer(sourceURLs: sourceURLs, sliceWidth: width, sliceHeight: height)
        let images = slicer.slicedImages()
        saveImages(images)
    }
    
    func saveImages(_ images: [CGImage]) {
        guard let sourceDir = sourceURLs.first?.deletingLastPathComponent() else { return }
        let destDir = sourceDir.appendingPathComponent("sliced", isDirectory: true)
        try? FileManager.default.createDirectory(at: destDir, withIntermediateDirectories: false, attributes: nil)
        for (i, v) in images.enumerated() {
            let destURL = destDir.appendingPathComponent("\(self.prefixField.stringValue)\(i+1).jpg", isDirectory: false) as CFURL
            guard let dest = CGImageDestinationCreateWithURL(destURL, "public.jpeg" as CFString, 1, nil) else { fatalError() }
            CGImageDestinationAddImage(dest, v, nil)
            CGImageDestinationFinalize(dest)
        }
    }
}

