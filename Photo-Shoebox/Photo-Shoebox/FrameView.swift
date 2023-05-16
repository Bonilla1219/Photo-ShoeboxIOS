//
//  FrameView.swift


import SwiftUI

struct FrameView: View {
    //Core Graphic Image
    var image: CGImage?
    
    var body: some View {
        if let image = image{
            Image(image, scale: 1.0, label: Text("Camera Capture Frame"))
                .resizable()
                .scaledToFit()
        }
        else{
            Color.black
        }
    }
}

struct FrameView_Previews: PreviewProvider {
    static var previews: some View {
        FrameView()
    }
}
