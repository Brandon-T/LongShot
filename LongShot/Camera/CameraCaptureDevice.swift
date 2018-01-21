//
//  CameraCaptureDevice.swift
//  LongShot
//
//  Created by Brandon on 2018-01-05.
//  Copyright © 2018 XIO. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public final class CameraCaptureDevice : UIView, AVCaptureMetadataOutputObjectsDelegate {
    private var device: AVCaptureDevice?
    private var input: AVCaptureDeviceInput?
    private var output: AVCaptureMetadataOutput?
    private var session: AVCaptureSession?
    private var preview: AVCaptureVideoPreviewLayer?
    private let queue = DispatchQueue(label: "com.longshot.camera.capture.device.queue")
    private (set) var onDataCaptured: ((_ metaData: AVMetadataObject, _ data: String?) -> Void)?
    
    public init(previewView: UIView) throws {
        super.init(frame: .zero)
        
        self.device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        if let device = self.device {
            self.input = try? AVCaptureDeviceInput(device: device)
            self.output = AVCaptureMetadataOutput()
            self.session = AVCaptureSession()
        }
        else {
            throw RuntimeError("Failed to create Capture Device.")
        }
        
        if let input = self.input, let output = self.output {
            self.session?.sessionPreset = .high
            self.session?.addInput(input)
            self.session?.addOutput(output)
            
            output.setMetadataObjectsDelegate(self, queue: self.queue)
            
            if let session = self.session {
                self.preview = AVCaptureVideoPreviewLayer(session: session)
                self.preview?.videoGravity = .resizeAspect
                
                if self.preview == nil {
                    throw RuntimeError("Failed to create Capture Device Preview Layer.")
                }
            }
            else {
                throw RuntimeError("Failed to create Capture Device Session.")
            }
        }
        else {
            if self.input == nil {
                throw RuntimeError("Failed to create Capture Device Input.")
            }
            
            if self.output == nil {
                throw RuntimeError("Failed to create Capture Device Output.")
            }
        }
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startCapturing(types: [AVMetadataObject.ObjectType]) {
        if let session = self.session, let input = self.input {
            if !session.inputs.contains(input) {
                session.addInput(input)
            }
        }
        
        if let session = self.session, let output = self.output {
            if !session.outputs.contains(output) {
                session.addOutput(output)
            }
        }
        
        if let preview = self.preview {
            self.layer.addSublayer(preview)
        }
        self.session?.commitConfiguration()
        self.session?.startRunning()
    }
    
    public func stopCapturing() {
        self.preview?.removeFromSuperlayer()
        
        if let session = self.session, let input = self.input {
            session.removeInput(input)
        }
        
        if let session = self.session, let output = self.output {
            session.removeOutput(output)
        }
        
        self.session?.stopRunning()
    }
    
    public class func getCameraPermissions(_ completion: @escaping (_ success: Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
            
        case .restricted:
            completion(false)
            
        case .denied:
            completion(false)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                completion(granted)
            })
        }
    }
    
    public class func hasCamera() -> Bool {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.count > 0
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.preview?.frame = self.bounds
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let onDataCaptured = self.onDataCaptured {
            for object in metadataObjects {
                let result: String? = (object as? AVMetadataMachineReadableCodeObject)?.stringValue
                onDataCaptured(object, result)
            }
        }
    }
}
