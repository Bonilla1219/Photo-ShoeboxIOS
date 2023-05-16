//
//  PhotoView.swift


import SwiftUI

struct PhotoView: View {
    @EnvironmentObject var store: PhotoStore
    @ObservedObject var photo: PhotoAsset
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    
    var body: some View {
        VStack{
            photo.image
                .resizable()
                .scaledToFit()
                .panAndZoom(scale: $scale, offset: $offset)
        }
        .navigationTitle(photo.url.path())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                NavigationLink("Edit", destination: PhotoEditView(photo: photo))
            }
            ToolbarItem(placement: .bottomBar){
                Button(action: {
                    print("Toggle is favoirited")
                    photo.isFavorite.toggle()
                    try? store.save()
                }, label:{
                    if photo.isFavorite{
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                            .transition(.confetti(color: .red, size: 3))
                    }
                    else{
                        Image(systemName: "heart")
                    }
                })
            }
            ToolbarItem(placement: .bottomBar){
                Button(action:{
                    print("delete")
                    store.delete(asset: photo)
                    dismiss()
                }, label: {
                    Image(systemName: "trash")
                })
            }
        }
        
        
    }
       
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            //PhotoView(photo: PhotoAsset(url: URL(String: "missing")))
        }
        
        
    }
}
