import Foundation
import ImageIO
import Quartz

struct ImageSlicer {
    let sourceURLs: [URL]
    let sliceWidth: Int
    let sliceHeight: Int
    
    func slicedImages() -> [CGImage] {
        var images = [CGImage]()
        for url in sourceURLs {
            guard let isrc = CGImageSourceCreateWithURL(url as CFURL, nil) else { fatalError() }
            guard let image = CGImageSourceCreateImageAtIndex(isrc, 0, nil) else { fatalError() }
            images.append(image)
        }
        let totalHeight = images.map({
            let whRatio = Double($0.width) / Double($0.height)
            let resizedHeight = Int(ceil(Double(self.sliceWidth) / whRatio))
            return resizedHeight
        }).reduce(0, +)
        guard let combinedContext = CGContext(data: nil,
                                              width: self.sliceWidth,
                                              height: totalHeight,
                                              bitsPerComponent: 8,
                                              bytesPerRow: self.sliceWidth * 4,
                                              space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).rawValue) else { fatalError() }
        
        var offsetY = 0
        for image in images.reversed() {
            let whRatio = Double(image.width) / Double(image.height)
            let resizedHeight = Int(ceil(Double(combinedContext.width) / whRatio))
            combinedContext.draw(image, in: CGRect(x: 0, y: offsetY, width: combinedContext.width, height: resizedHeight))
            offsetY += resizedHeight
        }
        guard let combinedImage = combinedContext.makeImage() else { fatalError() }
        
        let batchCount = Int(ceil(Double(totalHeight) / Double(self.sliceHeight)))
        
        images.removeAll()
        for i in 0..<batchCount {
            let cropRect = CGRect(x: 0, y: i * self.sliceHeight, width: combinedImage.width, height: self.sliceHeight)
            guard let croppedImage = combinedImage.cropping(to: cropRect) else { fatalError() }
            images.append(croppedImage)
        }
        return images
    }
    
}
