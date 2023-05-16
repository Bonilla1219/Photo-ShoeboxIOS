//
//  PhotoCatcher.swift


import UIKit
import AVFoundation
import Photos
import Foundation
import SwiftUI
import _PhotosUI_SwiftUI



class PhotoCatcher: NSObject, AVCapturePhotoCaptureDelegate {

    //@EnvironmentObject var store:PhotoStore
    var settings: AVCapturePhotoSettings
    var photoData: Data?
    var store:PhotoStore
    
    //@State var selectedItems: [PhotosPickerItem] = []
    
    
    
    
    init(settings photoSettings: AVCapturePhotoSettings, store: PhotoStore) {
        self.settings = photoSettings
        self.store = store
        
        super.init()
    }
    
    
    func uiimageFromData() -> UIImage? {
        if let data = photoData, let ciimage = CIImage(data: data) {
            let orig = UIImage(ciImage: ciimage)
            return orig.rotate(radians: .pi/2)
        }
        else {
            return nil
        }
    }
    
    
    // MARK: - AVCapturePhotoCaptureDelegate
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("didFinishProcessingPhoto")
        if let error = error {
            print("Error capturing photo.")
            print(error.localizedDescription)
        } else {
            photoData = photo.fileDataRepresentation()
            if photoData == nil {
                print("Warning, fileDataRepresentation returned nil")
            }
        }
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print("didFinishCaptureFor")
        if let error = error {
            print("Error capturing photo.")
            print(error.localizedDescription)
            return
        }
        
       
        savePhotoToContainer()
    }
    
    func savePhotoToContainer(){
        guard let data = photoData else {return}
        guard let image = UIImage(data: data) else {return}
        
        if let asset = PhotoAsset.create(image: image){
            store.photos.append(asset)
            try? store.save()
        }
    }
    
    
    
    func savePhotoDataToPhotoLibrary() {
        print("savePhotoDataToPhotoLibrary")
        guard let data = photoData else {
            print("No photo data resource in savePhotoDataToPhotoLibrary.")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                print("status - authorized")
                PHPhotoLibrary.shared().performChanges({
                    let options = PHAssetResourceCreationOptions()
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    options.uniformTypeIdentifier = self.settings.processedFileType.map { $0.rawValue }
                    creationRequest.addResource(with: .photo, data: data, options: options)
                    
                }, completionHandler: { _, error in
                    if let error = error {
                        print("Error occurered while saving photo to photo library.")
                        print(error.localizedDescription)
                    }
                }
                )
            } else {
                print("status - not authorized")
            }
        }
    }
    
    
}



extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
