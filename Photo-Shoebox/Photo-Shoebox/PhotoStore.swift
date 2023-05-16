//
//  PhotoStore.swift



import Foundation
import SwiftUI


enum PhotoStoreError: Error {
    case readArchiveError
    case writeArchiveError
    case decodeError
    case encodeError
}

class PhotoStore: Codable, ObservableObject {
        
    enum CodingKeys: CodingKey {
        case photos
    }
    
    static var documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    @Published var photos: [PhotoAsset]
    
    
    init(photos: [PhotoAsset]) {
        self.photos = photos
    }
    
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        photos = try container.decode([PhotoAsset].self, forKey: .photos)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(photos, forKey: .photos)
    }
    
    
    func delete(asset: PhotoAsset) {
        if let index = photos.firstIndex(of: asset) {
            photos.remove(at: index)
            do {
                try FileManager.default.removeItem(at: asset.absoluteURL)
            }
            catch {
                print(error.localizedDescription)
            }
            
            do {
                try save()
            }
            catch {
                print(error.localizedDescription)
            }
            
        }
        else {
            print("Warning, asset \(asset.url.path()) not found.")
        }
        
    }
    
    
    func save() throws {
        
        let url = PhotoStore.documentsDirectoryURL!.appendingPathComponent("PhotoStore").appendingPathExtension("plist")
        let encoder = PropertyListEncoder()
        var codedStore: Data
        do {
            codedStore = try encoder.encode(self)
        }
        catch {
            throw PhotoStoreError.encodeError
        }
        
        do {
            try codedStore.write(to: url)
        }
        catch {
            throw PhotoStoreError.writeArchiveError
        }
    }
    
    static func load() throws -> PhotoStore {
        let url = PhotoStore.documentsDirectoryURL!.appendingPathComponent("PhotoStore").appendingPathExtension("plist")
        guard let codedStore = try? Data(contentsOf: url) else {
            throw PhotoStoreError.readArchiveError
        }
        let decoder = PropertyListDecoder()
        do {
            let store = try decoder.decode(PhotoStore.self, from: codedStore)
            return store
        }
        catch {
            throw PhotoStoreError.decodeError
        }
        
    }
    
    func update(){
        objectWillChange.send()
    }
}
