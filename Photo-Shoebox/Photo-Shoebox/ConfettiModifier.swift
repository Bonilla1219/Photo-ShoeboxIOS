//
//  ConfettiModifier.swift


import Foundation
import SwiftUI


struct ConfettiModifier: ViewModifier {
    private let speed = 0.3
    @State private var circleSize = 0.00001
    @State private var strokeMultiplier = 1.0
    @State private var confettiIsHidden = true
    @State private var confettiMovement = 0.7
    @State private var confettiScale = 1.0
    @State private var contentsScale = 0.00001
    
    var color: Color
    var size: Double
    
    func body(content: Content) -> some View {
        content
            .hidden()
            .padding(10)
            .overlay(
                ZStack {
                    GeometryReader { proxy in
                        Circle()
                            .strokeBorder(color, lineWidth: proxy.size.width / 2 * strokeMultiplier)
                            .scaleEffect(circleSize)
                        ForEach(0..<15) { i in
                            Circle()
                                .fill(color)
                                .frame(width: size + sin(Double(i)), height: size + sin(Double(i)))
                                .scaleEffect(confettiScale)
                                .offset(x: proxy.size.width / 2 * confettiMovement + (i.isMultiple(of: 2) ? size : 0))
                                .rotationEffect(.degrees(24 * Double(i)))
                                .offset(x: (proxy.size.width - size) / 2, y: (proxy.size.height - size) / 2)
                                .opacity(confettiIsHidden ? 0 : 1)
                        }
                    }
                    content
                        .scaleEffect(contentsScale)
                }
            )
            .padding(-10)
            .onAppear {
                withAnimation(.easeIn(duration: speed)) {
                    circleSize = 1
                }
                withAnimation(.easeOut(duration: speed).delay(speed)) {
                    strokeMultiplier = 0.00001
                }
                withAnimation(.interpolatingSpring(stiffness: 50, damping: 5).delay(speed)) {
                    contentsScale = 1
                }
                withAnimation(.easeOut(duration: speed).delay(speed * 1.25)) {
                    confettiIsHidden = false
                    confettiMovement = 1.2
                }
                withAnimation(.easeOut(duration: speed).delay(speed * 2)) {
                    confettiScale = 0.00001
                }
            }
    }
}


extension AnyTransition {
    static var confetti: AnyTransition {
        .modifier(active: ConfettiModifier(color: .blue, size: 3),
                  identity: ConfettiModifier(color: .blue, size: 3))
    }
    
    static func confetti(color: Color = .blue, size: Double = 3.0) -> AnyTransition {
        AnyTransition.modifier(active: ConfettiModifier(color: color, size: size),
                               identity: ConfettiModifier(color: color, size: size))
    }
}
