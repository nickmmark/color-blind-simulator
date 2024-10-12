//
//  ViewController.swift
//  ColorBlindSimulator
//
//  Created by Nick Mark on 10/3/24.
//

import UIKit
import AVFoundation
import CoreImage

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var ciContext: CIContext!
    var videoCaptureDevice: AVCaptureDevice!
    
    var initialZoomFactor: CGFloat = 1.0

    @IBOutlet weak var cameraPreviewView: UIView!
    @IBOutlet weak var colorBlindnessToggle: UISegmentedControl!
    
    var ciImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Prevent the screen from dimming
        UIApplication.shared.isIdleTimerDisabled = true

        // Initialize the camera session
        captureSession = AVCaptureSession()
        ciContext = CIContext()

        print("Setting up the camera...")

        // Try to access the camera
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Error: Could not access the camera.")
            return
        }
        
        self.videoCaptureDevice = videoCaptureDevice

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
                print("Camera input added successfully.")
            } else {
                print("Error: Could not add camera input.")
                return
            }
        } catch {
            print("Error: Failed to create camera input - \(error.localizedDescription).")
            return
        }

        // Set up video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            print("Video output added successfully.")
        } else {
            print("Error: Could not add video output.")
            return
        }

        // Create and configure the preview layer for the camera feed
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = cameraPreviewView.bounds
        cameraPreviewView.layer.addSublayer(previewLayer) // Add preview layer to the cameraPreviewView

        print("Preview layer added to the cameraPreviewView.")

        // Create an overlay UIImageView to display the filtered image
        ciImageView = UIImageView(frame: cameraPreviewView.bounds)
        ciImageView.contentMode = .scaleAspectFill
        cameraPreviewView.addSubview(ciImageView)

        // Add pinch gesture recognizer for zooming
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        cameraPreviewView.addGestureRecognizer(pinchGesture)

        // Start the camera session
        captureSession.startRunning()
        if captureSession.isRunning {
            print("Camera capture session started.")
        } else {
            print("Error: Camera capture session failed to start.")
        }
    }

    // Handle the pinch gesture to zoom
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let device = videoCaptureDevice else { return }
        
        if gesture.state == .began {
            initialZoomFactor = device.videoZoomFactor
        }
        
        if gesture.state == .changed {
            let newZoomFactor = initialZoomFactor * gesture.scale
            
            // Clamp the zoom factor within the camera’s allowed zoom range
            let zoomFactor = max(1.0, min(newZoomFactor, device.activeFormat.videoMaxZoomFactor))

            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = zoomFactor
                device.unlockForConfiguration()
            } catch {
                print("Error locking configuration: \(error.localizedDescription)")
            }
        }
    }

    // Process the camera output (including the color blindness filter)
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Error: Could not get pixel buffer from sample buffer.")
            return
        }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        // Apply the selected color blindness filter
        let selectedIndex = colorBlindnessToggle.selectedSegmentIndex
        if let filteredImage = applyColorBlindnessFilter(to: ciImage, filterType: selectedIndex) {
            DispatchQueue.main.async {
                // Convert the CIImage to UIImage with correct orientation and display it
                let uiImage = UIImage(ciImage: filteredImage, scale: 1.0, orientation: .right) // Correct rotation
                self.ciImageView.image = uiImage
            }
        }
    }

    // Apply the selected color blindness filter using CIColorMatrix with adjusted values
    func applyColorBlindnessFilter(to image: CIImage, filterType: Int) -> CIImage? {
        let filter = CIFilter(name: "CIColorMatrix")!
        filter.setDefaults()
        filter.setValue(image, forKey: kCIInputImageKey)

        switch filterType {
        case 0:
            // print("Applying Protanopia filter.")
            // Protanopia (Red-Weakness)
            filter.setValue(CIVector(x: 0.567, y: 0.433, z: 0, w: 0), forKey: "inputRVector")  // Reduce Red
            filter.setValue(CIVector(x: 0.558, y: 0.442, z: 0, w: 0), forKey: "inputGVector")  // Keep Green
            filter.setValue(CIVector(x: 0, y: 0.242, z: 0.758, w: 0), forKey: "inputBVector")  // Boost Blue
            
        case 1:
            // print("Applying Deuteranopia filter.")
            // Deuteranopia (Green-Weakness)
            filter.setValue(CIVector(x: 0.625, y: 0.375, z: 0, w: 0), forKey: "inputRVector")  // Boost Red
            filter.setValue(CIVector(x: 0.7, y: 0.3, z: 0, w: 0), forKey: "inputGVector")      // Reduce Green
            filter.setValue(CIVector(x: 0, y: 0.3, z: 0.7, w: 0), forKey: "inputBVector")      // Keep Blue

        case 2:
            // print("Applying Tritanopia filter.")
            // Tritanopia (Blue-Weakness)
            filter.setValue(CIVector(x: 0.95, y: 0.05, z: 0, w: 0), forKey: "inputRVector")    // Mostly Red
            filter.setValue(CIVector(x: 0, y: 0.433, z: 0.567, w: 0), forKey: "inputGVector")  // Green with Blue
            filter.setValue(CIVector(x: 0, y: 0.475, z: 0.525, w: 0), forKey: "inputBVector")  // Reduce Blue

        case 3:
            // print("Displaying normal vision (no filter).")
            // Normal Vision (No Filter)
            return image
        default:
            return image
        }

        // Render the output of the filter with the current CIContext
        let extent = filter.outputImage?.extent ?? CGRect.zero
        guard let cgImage = ciContext.createCGImage(filter.outputImage!, from: extent) else {
            print("Error: Could not create CGImage from filtered CIImage.")
            return image
        }
        return CIImage(cgImage: cgImage)
    }

    @IBAction func colorBlindnessToggleChanged(_ sender: UISegmentedControl) {
        print("Toggle switched to index: \(sender.selectedSegmentIndex)")
    }
}

