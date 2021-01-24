//
//  LSGifBuilder.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 1/23/21.
//

import UIKit
import ImageIO
import MobileCoreServices

class LSGifBuilder {
    
    private var refreshRate: TimeInterval
    private var images: [UIImage]
    
    private var gifProperties: CFDictionary {
        [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFUnclampedDelayTime as String: refreshRate]] as CFDictionary
    }
    
    private static let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]] as CFDictionary
    
    init(refreshRate: TimeInterval) {
        self.refreshRate = refreshRate
        images = [UIImage]()
    }
    
    func addImage(_ image: UIImage) {
        images.append(image)
    }
    
    func getData() -> Data? {
        guard !images.isEmpty else { return nil }
        
        let data = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypeGIF, images.count, Self.fileProperties) else { return nil }
        
        for image in images {
            guard let cgImage = image.cgImage else { return nil }
            CGImageDestinationAddImage(destination, cgImage, gifProperties)
        }
        
        CGImageDestinationFinalize(destination)
        
        return data as Data
    }
}
