//
//  UIAlertController+SpiralSharing.swift
//  laser-spirograph
//
//  Created by Julian Tigler on 12/24/20.
//

import UIKit
import os.log

private typealias OptionHandler = (UIAlertAction) -> ()

extension UIAlertController {
    
    // MARK: Initialization

    class func spiralShareController(spiralName: String, spiralController: LSSpiralController, presentedFrom barButtonItem: UIBarButtonItem, presentingViewController: UIViewController) -> UIAlertController {
        let optionSheet = UIAlertController(title: "Share as", message: nil, preferredStyle: .actionSheet)
        optionSheet.popoverPresentationController?.barButtonItem = barButtonItem
        optionSheet.view.tintColor = presentingViewController.view.window?.tintColor
        
        let optionHandler: OptionHandler = { (alert) in
            addActivityIndicator(nextTo: barButtonItem)

            let format = SpiralExportFormat(rawValue: alert.title!)!
            imageData(with: format, using: spiralController) { (data) in                
                let fileName = "\(spiralName).\(format.rawValue.lowercased())"
                
                guard let url = save(data, with: fileName) else {
                    let alert = UIAlertController.okAlert(title: "Failed to create file", message: "Please try again later")
                    removeActivityIndicator(nextTo: barButtonItem)
                    presentingViewController.present(alert, animated: true)
                    return
                }
                
                let shareController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                shareController.popoverPresentationController?.barButtonItem = barButtonItem
                shareController.completionWithItemsHandler = fileCleanupHandler(for: url)
                
                presentingViewController.present(shareController, animated: true) {
                    removeActivityIndicator(nextTo: barButtonItem)
                }
            }
        }
        
        addOptions(to: optionSheet, with: optionHandler)
        
        return optionSheet
    }
    
    // MARK: Activity Indicator
    
    private class func addActivityIndicator(nextTo barButtonItem: UIBarButtonItem) {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .label
        activityIndicator.startAnimating()
        
        let activityIndicatorItem = UIBarButtonItem(customView: activityIndicator)
        barButtonItem.buttonGroup?.barButtonItems.append(activityIndicatorItem)
    }
    
    private class func removeActivityIndicator(nextTo barButtonItem: UIBarButtonItem) {
        guard let buttonGroup = barButtonItem.buttonGroup, buttonGroup.barButtonItems.last?.customView is UIActivityIndicatorView else { return }
        buttonGroup.barButtonItems.removeLast()
    }
    
    // MARK: Sharing options
    
    private enum SpiralExportFormat: String, CaseIterable {
        case svg = "SVG"
        case jpeg = "JPEG"
        case png = "PNG"
        case gif = "GIF"
    }
    
    private class func addOptions(to optionSheet: UIAlertController, with optionHandler: @escaping OptionHandler) {
        SpiralExportFormat.allCases.forEach() {
            optionSheet.addAction(UIAlertAction(title: $0.rawValue, style: .default, handler: optionHandler))
        }
        
        optionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    }
    
    private class func imageData(with format: SpiralExportFormat, using spiralController: LSSpiralController, completion: @escaping (Data?) -> ()) {
        DispatchQueue.main.async {
            switch format {
            case .svg:
                let exporter = spiralController.getSvgExporter()
                completion(exporter?.description.data(using: .utf8))
            case .jpeg:
                completion(spiralController.getImage()?.jpegData(compressionQuality: 1.0))
            case .png:
                completion(spiralController.getImage()?.pngData())
            case .gif:
                spiralController.gifData() { completion($0) }
            }
        }
    }
    
    // MARK: File operations
    
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
