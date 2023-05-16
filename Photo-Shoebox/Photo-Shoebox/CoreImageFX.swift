//
//  CoreImageFX.swift



import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins


func errorResult() -> UIImage {
    return UIImage(systemName: "exclamationmark.circle.fill")!
}

func filterSepia(photo: UIImage) async -> UIImage {
    guard let sourceImage = CIImage(image: photo) else {
        return errorResult()
    }
    let currentFilter = CIFilter.sepiaTone()
    currentFilter.inputImage = sourceImage
    currentFilter.intensity = 1
    
    guard let outputImage = currentFilter.outputImage else {
        return errorResult()
    }
    let context = CIContext()
    if let resultImage = context.createCGImage(outputImage, from: sourceImage.extent) {
        return UIImage(cgImage: resultImage, scale: 1.0, orientation: photo.imageOrientation)
    }
    return errorResult()
}

func filterExposure(photo: UIImage, exposureValue: Float) -> UIImage {
    guard let sourceImage = CIImage(image: photo) else {
        return errorResult()
    }
    let currentFilter = CIFilter.exposureAdjust()
    currentFilter.inputImage = sourceImage
    currentFilter.ev = exposureValue
    
    guard let outputImage = currentFilter.outputImage else {
        return errorResult()
    }
    let context = CIContext()
    if let resultImage = context.createCGImage(outputImage, from: sourceImage.extent) {
        return UIImage(cgImage: resultImage, scale: 1.0, orientation: photo.imageOrientation)
    }
    return errorResult()
}


func filterPhotoAndBloom(photo: UIImage) async -> UIImage {
    guard let sourceImage = CIImage(image: photo) else {
        return errorResult()
    }
    let photoFilter = CIFilter.photoEffectProcess()
    photoFilter.inputImage = sourceImage
    
    let bloomFilter = CIFilter.bloom()
    bloomFilter.inputImage = photoFilter.outputImage
    bloomFilter.radius = 10.0
    bloomFilter.intensity = 1.0
    
    guard let outputImage = bloomFilter.outputImage else {
        return errorResult()
    }
    let context = CIContext()
    if let resultImage = context.createCGImage(outputImage, from: sourceImage.extent) {
        return UIImage(cgImage: resultImage, scale: 1.0, orientation: photo.imageOrientation)
    }
    return errorResult()
}

//adds crystals to the image 
func filterCrystallize(photo: UIImage) async -> UIImage {
    guard let sourceImage = CIImage(image: photo) else {
        return errorResult()
    }
    
    let currentFilter = CIFilter.crystallize()
    currentFilter.inputImage = sourceImage
    currentFilter.radius = 50.00
    currentFilter.center = CGPoint(x: 150, y: 150)
    
    guard let outputImage = currentFilter.outputImage else {
        return errorResult()
    }
    let context = CIContext()
    if let resultImage = context.createCGImage(outputImage, from: sourceImage.extent) {
        return UIImage(cgImage: resultImage, scale: 1.0, orientation: photo.imageOrientation)
    }
    return errorResult()
}

//Noir makes the picture in black and white
func filterNoir(photo: UIImage) async -> UIImage {
    guard let sourceImage = CIImage(image: photo) else {
        return errorResult()
    }
    
    //noir and Gloom effect to make it look like a comic book
    let currentFilter = CIFilter.photoEffectNoir()
    currentFilter.inputImage = sourceImage
    
    guard let outputImage = currentFilter.outputImage else {
        return errorResult()
    }
    let context = CIContext()
    if let resultImage = context.createCGImage(outputImage, from: sourceImage.extent) {
        return UIImage(cgImage: resultImage, scale: 1.0, orientation: photo.imageOrientation)
    }
    return errorResult()
}

//gloom features makes it look more like comic book
func filterGloom(photo: UIImage, intensityValue: Float) -> UIImage {
    guard let sourceImage = CIImage(image: photo) else {
        return errorResult()
    }
    
    //noir and Gloom effect to make it look like a comic book
    let gloomFilter = CIFilter.gloom()
    gloomFilter.inputImage = sourceImage
    gloomFilter.radius = 10.0
    gloomFilter.intensity = intensityValue
    
    guard let outputImage = gloomFilter.outputImage else {
        return errorResult()
    }
    let context = CIContext()
    if let resultImage = context.createCGImage(outputImage, from: sourceImage.extent) {
        return UIImage(cgImage: resultImage, scale: 1.0, orientation: photo.imageOrientation)
    }
    return errorResult()
}

//allows for the gammma of the image to be changed with a slider
func filterTransferAndGamma(photo: UIImage, powerValue: Float) -> UIImage {
    guard let sourceImage = CIImage(image: photo) else {
        return errorResult()
    }
    
    let currentFilter = CIFilter.photoEffectTransfer()
    currentFilter.inputImage = sourceImage
    
    //noir and Gloom effect to make it look like a comic book
    let gammaFilter = CIFilter.gammaAdjust()
    gammaFilter.inputImage = sourceImage
    gammaFilter.power = powerValue
    
    guard let outputImage = gammaFilter.outputImage else {
        return errorResult()
    }
    let context = CIContext()
    if let resultImage = context.createCGImage(outputImage, from: sourceImage.extent) {
        return UIImage(cgImage: resultImage, scale: 1.0, orientation: photo.imageOrientation)
    }
    return errorResult()
}


func filterTransfer(photo: UIImage) -> UIImage {
    guard let sourceImage = CIImage(image: photo) else {
        return errorResult()
    }
    
    let currentFilter = CIFilter.photoEffectTransfer()
    currentFilter.inputImage = sourceImage
    
    
    guard let outputImage = currentFilter.outputImage else {
        return errorResult()
    }
    let context = CIContext()
    if let resultImage = context.createCGImage(outputImage, from: sourceImage.extent) {
        return UIImage(cgImage: resultImage, scale: 1.0, orientation: photo.imageOrientation)
    }
    return errorResult()
}



