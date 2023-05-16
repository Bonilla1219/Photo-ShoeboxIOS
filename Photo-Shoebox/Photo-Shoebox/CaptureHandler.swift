//
//  CaptureHandler.swift

import Foundation
import AVFoundation
import CoreImage

class CaptureHandler: NSObject, ObservableObject{
    
    @Published var frame: CGImage?
        
        private var permissionGranted = false
        private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    
        private let captureSession = AVCaptureSession()
        private var videoOutput = AVCaptureVideoDataOutput()
        private let photoOutput = AVCapturePhotoOutput()
    
    
        private let context = CIContext()
        private var catcher: PhotoCatcher!
    
        private var currentCaptureDevice: AVCaptureDevice?
        private var currentCaptureInput: AVCaptureInput?
        
        private let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera, .builtInDualCamera, .builtInTripleCamera, .builtInDualWideCamera, .builtInTrueDepthCamera, .builtInLiDARDepthCamera]
        var discoverySession: AVCaptureDevice.DiscoverySession?
        
        override init() {
            super.init()
            Task{
                await checkCameraPermission()
                self.configure()
                self.captureSession.startRunning()
            }
            
        }
        
        // Check to see if that app has permission to use the camera.
        // If it hasn't been determined, call requestPermission to ask the user.
        func checkCameraPermission() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                // User has granted access to the camera.
                permissionGranted = true
                
            case .notDetermined:
                // The user has not yet been asked for camera access.
                requestPermission()
                    
            // Combine the two other cases into the default case
            default:
                permissionGranted = false
            }
        }
        
        // Prompt the system to ask the user if app can use the Camera.
        func requestPermission() {
            AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
                self.permissionGranted = granted
            }
        }
        
        // Configure the Capture Session, setup the inputs and outputs.
        func configure() {
            guard permissionGranted else { return }
            
            captureSession.beginConfiguration()
            
            discoverCaptureDevices()
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
            captureSession.addInput(videoDeviceInput)
            currentCaptureDevice = videoDevice
            currentCaptureInput = videoDeviceInput
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
            captureSession.addOutput(videoOutput)
            
            videoOutput.connection(with: .video)?.videoOrientation = .portrait
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            captureSession.commitConfiguration()
        }
        
        // Ask the photoOutput to capture a still photo.
    func capturePhoto(store: PhotoStore) {
            let formatSettings = [
                AVVideoCodecKey : AVVideoCodecType.jpeg,
                AVVideoCompressionPropertiesKey: [AVVideoQualityKey : NSNumber(value: 0.9)]
            ] as [String : Any]
            let photoSettings = AVCapturePhotoSettings(format: formatSettings)
            
            if let device = currentCaptureDevice, device.isFlashAvailable {
                photoSettings.flashMode = .auto
            }
            
            photoSettings.isDepthDataDeliveryEnabled = false
            
            catcher = PhotoCatcher(settings: photoSettings, store: store)
            self.photoOutput.capturePhoto(with: photoSettings, delegate: catcher)
        }
        
        // Find out what cameras exist on the current device.
        func discoverCaptureDevices() {
            discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .unspecified)
            guard let discovery = discoverySession else { return }
            for device in discovery.devices {
                print("-------------------")
                print("uniqueID: \(device.uniqueID)")
                print("modelID: \(device.modelID)")
                print("name: \(device.localizedName)")
                print("manufacturer: \(device.manufacturer)")
                print("device type: \(device.deviceType.rawValue)")
                switch device.position {
                    case .front:
                        print("device position: front")
                    case .back:
                        print("device position: back")
                    case .unspecified:
                        print("device position: unspecified")
                    default:
                        print("device position: unknown")
                }
            }
        }
        
        // Change to a different camera
        func changeCameraInput(device: AVCaptureDevice) {
            if let captureInput = currentCaptureInput {
                captureSession.removeInput(captureInput)
            }
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device) else { return }
            guard captureSession.canAddInput(videoDeviceInput) else { return }
            currentCaptureDevice = device
            currentCaptureInput = videoDeviceInput
            captureSession.addInput(videoDeviceInput)
            videoOutput.connection(with: .video)?.videoOrientation = .portrait
            captureSession.commitConfiguration()
        }
        
        // return true if device is the current input for capture
        func isCurrentInput(device: AVCaptureDevice) -> Bool {
            return device.uniqueID == currentCaptureDevice?.uniqueID
        }
        
        // set the output orientation
        func changeOrientation(orientation: AVCaptureVideoOrientation) {
            videoOutput.connection(with: .video)?.videoOrientation = orientation
            captureSession.commitConfiguration()
        }
}

extension CaptureHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // delegate method for capture, this method recieves the pixels for one frame.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async { [self] in
            self.frame = cgImage
        }
    }
    
    // convert the pixel data (CMSamplebuffer) into a CGImage object.
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return cgImage
    }
}
