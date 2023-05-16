//
//  ContentView.swift


import SwiftUI
import AVFoundation


struct ContentView: View {
    @EnvironmentObject var store:PhotoStore
    @StateObject private var capture = CaptureHandler()
    
    var body: some View {
        
        ZStack {
            Color.black
            FrameView(image: capture.frame)
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbarColorScheme(.dark, for: .tabBar, .navigationBar)
        .toolbar{
            ToolbarItemGroup(placement: .bottomBar)
            {
                Spacer()
                Button(action: {
                    capture.capturePhoto(store: store)
                }, label:{
                    Image(systemName:"camera.circle")
                        .font(.largeTitle)
                })
                Spacer()
                Menu {
                    ForEach(capture.discoverySession?.devices ?? [], id: \.uniqueID){
                        device in
                        Button(action:{
                            capture.changeCameraInput(device: device)
                        }, label: {
                            if capture.isCurrentInput(device: device){
                                Label(device.localizedName, systemImage: "camera.fill")
                            }
                            else{
                                Label(device.localizedName, systemImage: "camera")
                            }
                        })
                    }
                } label:{
                    Label("Camera Menu", systemImage: "arrow.triangle.2.circlepath.camera")
                }
            }
        }
        .onRotate {newOrientation in
            print("rotate: \(newOrientation)")
            handleRotate(newOrientation: newOrientation)
    }
    }
    
    
    
    func handleRotate(newOrientation: UIDeviceOrientation){
        switch newOrientation{
        case .portrait:
            capture.changeOrientation(orientation: .portrait)
        case .portraitUpsideDown:
            print("ignore")
        case .landscapeLeft:
            capture.changeOrientation(orientation: .landscapeRight)
        case .landscapeRight:
            capture.changeOrientation(orientation: .landscapeLeft)
        default:
            print("ignore unknown, upside down, face up, face down")
        }
    }
    
    
}


struct DeviceOrientationViewModifier: ViewModifier{
    let action: (UIDeviceOrientation) -> Void
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)){
                _ in action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation)->Void) -> some View{
        self.modifier(DeviceOrientationViewModifier(action: action))
    }
}
