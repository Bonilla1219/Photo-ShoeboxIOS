//
//  PhotoEditView.swift


import SwiftUI

struct PhotoEditView: View {
    @EnvironmentObject var store: PhotoStore
    @ObservedObject var photo: PhotoAsset
    @State private var working: UIImage = UIImage()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showFilterTool = false
    @State private var showExposureTool = false
    @State private var exposureValue: Float = 0.0
    
    @State private var showIntensityTool = false
    @State private var intensityValue: Float = 0.0
    
    @State private var showGammaTool = false
    @State private var gammaValue: Float = 0.75
    
    @State private var scale: CGFloat = 1.0
    @State private var offest: CGSize = .zero
    
    
    
    
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            VStack{
                Image(uiImage: working)
                    .resizable()
                    .scaledToFit()
                    .panAndZoom(scale: $scale, offset: $offest)
                if showFilterTool{
                    HStack{
                        Button("Cancel", action: {
                            working = photo.sourceImage!
                            withAnimation{
                                
                                showFilterTool = false
                            }
                        })
                        Spacer()
                        Button("Done", action: {
                            photo.update(updated: working)
                            store.update()
                            withAnimation{
                                
                                showFilterTool = false
                            }
                            
                        })
                    }
                }
                if showExposureTool{
                    VStack{
                        HStack{
                            Slider(value: $exposureValue, in: -2...2)
                                .onChange(of: exposureValue, perform: { _ in
                                    self.doExposureFilter()
                                })
                            TextField("", value: $exposureValue, format: .number.precision(.fractionLength(3)))
                                .foregroundColor(.white)
                                .fixedSize()
                        }
                        HStack{
                            Button("Cancel", action: {
                                working = photo.sourceImage!
                                withAnimation{
                                    exposureValue = 0.0
                                    showExposureTool.toggle()
                                }
                            })
                            Spacer()
                            Button("Done", action: {
                                photo.update(updated: working)
                                store.update()
                                withAnimation{
                                    exposureValue = 0.0
                                    showExposureTool.toggle()
                                }
                                
                            })
                        }
                    }
                    
                }
                if showIntensityTool{
                    VStack{
                        
                        HStack{
                            Slider(value: $intensityValue, in: 0...2)
                                .onChange(of: intensityValue, perform: { _ in
                                    self.doGloom()
                                })
                            TextField("", value: $intensityValue, format: .number.precision(.fractionLength(3)))
                                .foregroundColor(.white)
                                .fixedSize()
                        }
                        HStack{
                            Button("Cancel", action: {
                                working = photo.sourceImage!
                                withAnimation{
                                    intensityValue = 0.0
                                    showExposureTool.toggle()
                                }
                            })
                            Spacer()
                            Button("Done", action: {
                                photo.update(updated: working)
                                store.update()
                                withAnimation{
                                    intensityValue = 0.0
                                    showExposureTool.toggle()
                                }
                                
                            })
                        }
                    }
                    
                }
                if showGammaTool{
                    VStack{
                        
                        HStack{
                            Slider(value: $gammaValue, in: 0...2)
                                .onChange(of: gammaValue, perform: { _ in
                                    self.doTransferAndGamma()
                                })
                            TextField("", value: $gammaValue, format: .number.precision(.fractionLength(3)))
                                .foregroundColor(.white)
                                .fixedSize()
                        }
                        HStack{
                            Button("Cancel", action: {
                                working = photo.sourceImage!
                                withAnimation{
                                    gammaValue = 0.75
                                    showGammaTool.toggle()
                                }
                            })
                            Spacer()
                            Button("Done", action: {
                                photo.update(updated: working)
                                store.update()
                                withAnimation{
                                    gammaValue = 0.75
                                    showGammaTool.toggle()
                                }
                                
                            })
                        }
                    }
                    
                }
                    
                
            }
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .bottomBar, .tabBar, .automatic, .navigationBar)
            .toolbarBackground(.visible, for: .bottomBar, .tabBar, .automatic, .navigationBar)
            .toolbarColorScheme(.dark , for: .bottomBar, .tabBar, .automatic, .navigationBar)
            .toolbar{
                ToolbarItemGroup(placement: .bottomBar){
                    Spacer()
                    Button(action:{
                        withAnimation{
                            showExposureTool.toggle()
                        }
                        
                    }, label: {
                        Image(systemName: "plusminus.circle")
                    })
                    Menu("Filters"){
                        Button("Sepia", action: doSepiaFilter)
                        Button("Photo and Bloom", action: doPhotoAndBloomFilter)
                        Button("Crystallize", action: doCrystallize)
                        Button("Noir", action: doNoir)
                        Button("Gloom", action: {doGloom(); showIntensityTool.toggle()})
                        Button("Transfer And Gamma", action: {doTransferAndGamma(); showGammaTool.toggle()})
                        Button("Transfer", action: doTransfer)
                        
                        
                    }
                }
                
            }
        }
        .onAppear{
            photo.createOriginalIfNeeded()
            working = photo.sourceImage!
        }
        
        
    }
    func doSepiaFilter(){
        Task{
            working = await filterSepia(photo: photo.sourceImage!)
        }
        
        withAnimation{
            showFilterTool = true
        }
    }
    
    func doPhotoAndBloomFilter(){
        Task{
            working = await filterPhotoAndBloom(photo: photo.sourceImage!)
        }
        
        withAnimation{
            showFilterTool = true
        }
    }
    
    func doCrystallize(){
        Task{
            working = await filterCrystallize(photo: photo.sourceImage!)
        }
        
        withAnimation{
            showFilterTool = true
        }
    }
    
    func doNoir(){
        Task{
            working = await filterNoir(photo: photo.sourceImage!)
        }
        
        withAnimation{
            showFilterTool = true
        }
       
    }
    
    func doGloom(){
        working = filterGloom(photo: photo.sourceImage!, intensityValue: intensityValue)
    }
    
    func doTransferAndGamma(){
        working = filterTransferAndGamma(photo: photo.sourceImage!, powerValue: gammaValue)
    }
    
    func doTransfer(){
        working = filterTransfer(photo: photo.sourceImage!)
    }
    
    func doExposureFilter(){
        working = filterExposure(photo: photo.sourceImage!, exposureValue: exposureValue)
        
    }
    
}
//
//struct PhotoEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoEditView()
//    }
//}
