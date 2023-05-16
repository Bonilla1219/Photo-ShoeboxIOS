//
//  PanAndZoom.swift


import Foundation
import SwiftUI


struct PanAndZoom: ViewModifier {
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    
    @State private var currentScale: CGFloat = 0.0
    @State private var currentOffset: CGSize = .zero
    
    private var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                currentOffset = gesture.translation
            }
            .onEnded { _ in
                offset = offset + currentOffset
                currentOffset = .zero
            }
    }
    
    private var magnify: some Gesture {
        MagnificationGesture()
            .onChanged { amount in
                currentScale = amount - 1
            }
            .onEnded { amount in
                scale += currentScale
                currentScale = 0.0
            }
    }
    
    private var doubletap: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                scale = 1.0
                offset = .zero
            }
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale + currentScale)
            .offset(offset + currentOffset)
            .gesture(drag)
            .gesture(magnify)
            .gesture(doubletap)
    }
}


extension View {
    func panAndZoom(scale: Binding<CGFloat>, offset: Binding<CGSize>) -> some View {
        modifier(PanAndZoom(scale: scale, offset: offset))
    }
}

extension CGSize {
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
}

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

