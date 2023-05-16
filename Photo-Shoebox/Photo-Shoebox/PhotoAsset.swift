//
//  PhotoAsset.swift


import Foundation
import SwiftUI
import UniformTypeIdentifiers


class PhotoAsset: Identifiable, Codable, ObservableObject, Hashable, Equatable {
    static var documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    let id: UUID
    var url: URL
    @Published var isFavorite: Bool
    var contentType: UTType
    
    enum CodingKeys: CodingKey {
        case id
        case url
        case isFavorite
        case contentType
    }
    
    init(id: UUID, url: URL, isFavorite: Bool, contentType: UTType) {
        self.id = id
        self.url = url
        self.isFavorite = isFavorite
        self.contentType = contentType
    }
    
    convenience init(url: URL, contentType: UTType) {
        self.init(id: UUID(), url: url, isFavorite: false, contentType: contentType)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        return lhs.id == rhs.id
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        url = try container.decode(URL.self, forKey: .url)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        do {
            contentType = try container.decode(UTType.self, forKey: .contentType)
        }
        catch {
            contentType = .jpeg
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(contentType, forKey: .contentType)
    }
    
    var image: Image {
        return Image(uiImage: uiImage)
    }
    var sourceImage: UIImage?
    
    var uiImage: UIImage {
        if sourceImage == nil {
            if let img = UIImage(contentsOfFile: absoluteURL.path()) {
                sourceImage = img
                return img
            }
            else {
                print("PhotoAsset, sourceImage is still nil")
                return UIImage(systemName: "photo")!
            }
        }
        else {
            return sourceImage!
        }
    }
    
    var absoluteURL: URL {
        PhotoAsset.documentsDirectoryURL!.appending(component: url.path())
    }
    
    static func create(image: UIImage) -> PhotoAsset? {
        let jpegQuality:CGFloat = 0.9
        if let data = image.jpegData(compressionQuality: jpegQuality){
            
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYYMMdd_HHmmss"
            let timeStamp = formatter.string(from: now)
            let filename = "photo_\(timeStamp).jpg"
            
            let url  = documentsDirectoryURL!.appending(path: filename)
            do{
                try data.write(to: url)
                return PhotoAsset(url: URL(string: filename)!, contentType: .jpeg)
            }
            catch{
                print(error)
                print(error.localizedDescription)
                return nil
            }
        }
        else{
            print("Warning, unable to create jpeg data.")
            return nil
        }
            
    }
    
}

extension PhotoAsset: Transferable {
    
    static var transferRepresentation: some TransferRepresentation {
        
        FileRepresentation(importedContentType: .jpeg, importing: { received in
            print("jpeg")
            return copyReceivedFile(received, contentType: .jpeg)
        })
        
        FileRepresentation(importedContentType: .png, importing: { received in
            print("png")
            return copyReceivedFile(received, contentType: .png)
        })
        
        FileRepresentation(importedContentType: .heif, importing: { received in
            print("heif")
            return copyReceivedFile(received, contentType: .heif)
        })
        
      
    }
    
    static func copyReceivedFile(_ received: ReceivedTransferredFile, contentType: UTType) -> PhotoAsset {
        guard let assetUrl = URL(string: received.file.lastPathComponent) else {
            return PhotoAsset(url: URL(string:"missing")!, contentType: .jpeg)
        }
        let copyDestination = documentsDirectoryURL!.appending(path:assetUrl.path())
        print(copyDestination)
        try? FileManager.default.copyItem(at: received.file, to: copyDestination)
        
        return PhotoAsset(url: assetUrl, contentType: contentType)
    }
}

extension PhotoAsset {
    static func createOriginalsFolderIfNeeded() {
        let originals = documentsDirectoryURL!.appending(path: "originals")
        if FileManager.default.fileExists(atPath: originals.path()) == false {
            do {
                try FileManager.default.createDirectory(at: originals, withIntermediateDirectories: true)
            }
            catch {
                print(error)
            }
        }
    }
    
    func createOriginalIfNeeded() {
        PhotoAsset.createOriginalsFolderIfNeeded()
        let original = PhotoAsset.documentsDirectoryURL!.appending(path: "originals").appending(path: url.path())
        if FileManager.default.fileExists(atPath: original.path()) == false {
            do {
                try FileManager.default.copyItem(at: absoluteURL, to: original)
                print("created original at \(original.path())")
            }
            catch {
                print(error)
            }
        }
    }
    
    // TODO: handle images other than jpegs
    func update(updated: UIImage) {
        let compressionQuality = 0.95  // how to pick this value better?
        if let data = updated.jpegData(compressionQuality: compressionQuality) {
            do {
                try data.write(to: absoluteURL)
                sourceImage = nil
            }
            catch {
                print(error)
            }
        }
        else {
            print("unable to create jpeg data")
        }
    }
    
    func updatePng(updated: UIImage) {
        if let data = updated.pngData()
        {
            do {
                try data.write(to: absoluteURL)
                sourceImage = nil
            }
            catch {
                print(error)
            }
        }
        else {
            print("unable to create png data")
        }
    }
}
