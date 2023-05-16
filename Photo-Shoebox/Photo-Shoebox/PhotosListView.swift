//
//  PhotosListView.swift



import SwiftUI
import _PhotosUI_SwiftUI

/*only works for text and other things that are not Images*/

//struct HeavyText: ViewModifier{
//    func body(content: Content) -> some View {
//        content
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//            .clipped()
//            .aspectRatio(1, contentMode: .fit)
//            .clipShape(RoundedRectangle(cornerRadius: 4))
//    }
//}

struct PhotosListView: View {
    
    @EnvironmentObject var store:PhotoStore
    @State var selectedItems: [PhotosPickerItem] = []
    @State private var isFilteredList:Bool = false
    
    let columns = [GridItem(.adaptive(minimum: 80))]
    var photosForList:[PhotoAsset]{
        if isFilteredList{
            return store.photos.filter({$0.isFavorite == true})
        }
        else{
            return store.photos
        }
    }
    var body: some View {
        NavigationStack{
            ScrollView{
                LazyVGrid(columns: columns){
                    ForEach(photosForList){asset in
                        NavigationLink(value: asset){
                            asset.image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .clipped()
                                .aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            
                        }
                    }
                }
                .navigationDestination(for: PhotoAsset.self){ asset in
                    PhotoView(photo: asset)
                    
                }
            }
            .padding()
            .navigationTitle("Libary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button(action:{
                    withAnimation{
                        isFilteredList.toggle()
                    }
                }, label: {
                    if isFilteredList{
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    }
                    else{
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                })
                PhotosPicker(selection: $selectedItems, matching: .images){
                    Image(systemName: "plus")
                }
                
                NavigationLink(destination: ContentView()){
                    Label("Camera", systemImage: "camera")
                }
                
            }
            .onChange(of: selectedItems){ _ in
                importSelectedPhotosFromSytemLibary()
            }
        }
        
    }
    
    func importSelectedPhotosFromSytemLibary(){
        Task{
            for item in selectedItems {
                if let asset = try? await item.loadTransferable(type: PhotoAsset.self){
                    store.photos.append(asset)
                }
                else{
                    print("LoadTransferrable failed")
                }
            }
            
            try? store.save()
        }
        
    }
}

struct PhotosListView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosListView()
    }
}
