//
//  Photo_ShoeboxApp.swift


import SwiftUI

@main
struct Photo_ShoeboxApp: App {
    var store: PhotoStore
    
    init(){
        do{
            self.store = try PhotoStore.load()
        }
        catch{
            self.store = PhotoStore(photos: [])
        }
    }
    
    var body: some Scene {
        WindowGroup {
            PhotosListView()
                .environmentObject(store)
        }
    }
}
