//
//  UIAlertController+SpiralSharing.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/24/20.
//

import UIKit
import os.log

enum SpiralExportFormat: String, CaseIterable {
    case svg = "SVG"
    case jpeg = "JPEG"
    case png = "PNG"
}

private typealias OptionHandler = (UIAlertAction) -> ()

extension UIAlertController {

    class func spiralShareController(spiralName: String, spiralController: LSSpiralController, presentingViewController: UIViewController) -> UIAlertController {
        let optionSheet = UIAlertController(title: "Share as", message: nil, preferredStyle: .actionSheet)
        optionSheet.view.tintColor = .green
        
        let optionHandler: OptionHandler = { (alert) in
            let format = SpiralExportFormat(rawValue: alert.title!)!
            let data = imageData(with: format, using: spiralController)
            let fileName = "\(spiralName).\(format.rawValue.lowercased())"
            
            guard let url = save(data, with: fileName) else {
                let alert = UIAlertController.okAlert(title: "Failed to create file", message: "Please try again later")
                presentingViewController.present(alert, animated: true)
                return
            }
            
            let shareController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            shareController.completionWithItemsHandler = fileCleanupHandler(for: url)
            presentingViewController.present(shareController, animated: true)
        }
        
        addOptions(to: optionSheet, with: optionHandler)
        
        return optionSheet
    }
    
    private class func addOptions(to optionSheet: UIAlertController, with optionHandler: @escaping OptionHandler) {
        SpiralExportFormat.allCases.forEach() {
            optionSheet.addAction(UIAlertAction(title: $0.rawValue, style: .default, handler: optionHandler))
        }
        
        optionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    }
    
    private class func imageData(with format: SpiralExportFormat, using spiralController: LSSpiralController) -> Data? {
        switch format {
        case .svg:
            let exporter = spiralController.getSvgExporter()
            return exporter?.description.data(using: .utf8)
        case .jpeg:
            return spiralController.getImage()?.jpegData(compressionQuality: 1.0)
        case .png:
            return spiralController.getImage()?.pngData()
        }
    }
    
    private class func save(_ data: Data?, with fileName: String) -> URL? {
        guard let data = data else { return nil }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let sanitizedFileName = fileName.replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ":", with: ".")
        let url = documentsDirectory.appendingPathComponent(sanitizedFileName)

        do {
            try data.write(to: url)
        } catch {
            os_log("Failed to save %@ with error: %@", sanitizedFileName, error.localizedDescription)
            return nil
        }

        return url
    }
    
    private class func fileCleanupHandler(for url: URL) -> UIActivityViewController.CompletionWithItemsHandler {
        { (activityType, completed, _, _) in
            guard completed || (activityType == nil) else { return }
            deleteFile(at: url)
        }
    }
    
    private class func deleteFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            os_log("Failed to delete file at %@ with error: %@", url.absoluteString, error.localizedDescription)
        }
    }
}
