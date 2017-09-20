//
//  ViewController.swift
//  cameraDemo
//
//  Created by Ryosuke Nakagawa on 2017/09/20.
//  Copyright © 2017年 Ryosuke Nakagawa. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIGestureRecognizerDelegate, AVCapturePhotoCaptureDelegate {
    
    var input: AVCaptureDeviceInput!
    var output: AVCapturePhotoOutput!
    var session: AVCaptureSession!
    
    var preView: UIView!
    var camera: AVCaptureDevice!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapped(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupDisplay()
        
        setupCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        session = nil
        camera = nil
    }
    
    func setupDisplay() {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        preView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
    }
    
    func setupCamera() {
        session = AVCaptureSession()
        
        camera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                                               mediaType: AVMediaTypeVideo,
                                               position: .back)
        
        do {
            input = try AVCaptureDeviceInput(device: camera)
        } catch let error as NSError {
            print(error)
        }
        
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        output = AVCapturePhotoOutput()
        
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer?.frame = preView.frame
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.view.layer.addSublayer(previewLayer!)
        
        session.startRunning()
    }
    
    func tapped(_ sender: UITapGestureRecognizer) {
        print("tapped")
        takeStillPicture()
    }

    func takeStillPicture() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = false
        
        output?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput,
                 didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
                 previewPhotoSampleBuffer: CMSampleBuffer?,
                 resolvedSettings: AVCaptureResolvedPhotoSettings,
                 bracketSettings: AVCaptureBracketedStillImageSettings?,
                 error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        savePhoto(imageDataBuffer: photoSampleBuffer!)
    }
    
    func savePhoto(imageDataBuffer: CMSampleBuffer) {
        if let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: imageDataBuffer,
                                                             previewPhotoSampleBuffer: nil),
        let photo = UIImage(data: imageData) {
            UIImageWriteToSavedPhotosAlbum(photo, self, nil, nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

