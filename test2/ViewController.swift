//
//  ViewController.swift
//  test2
//
//  Created by Intern on 2018/11/13.
//  Copyright © 2018年 Intern. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVCapturePhotoCaptureDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var captureSession = AVCaptureSession()
    
    var mainCamera : AVCaptureDevice?
    var innerCamera : AVCaptureDevice?
    var currentDevice : AVCaptureDevice?
    var photoOutput : AVCapturePhotoOutput?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    
    //var isBackCamera : Bool = true
    
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var imageVIew: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupCaptureSession()
        //setupDevice()
        //setupInputOutput()
        //setupPreviewLayer()
        //captureSession.startRunning()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        
        settings.flashMode = .auto
        settings.isAutoStillImageStabilizationEnabled = true
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
        imageVIew.image = nil
    }
    @IBAction func startCamera(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .camera
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
        //flag = true
    }
    @IBAction func startAlbum(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.imageVIew.image = image
        self.imageVIew.contentMode = UIViewContentMode.scaleAspectFit
        self.dismiss(animated: true, completion: nil)
    }
}


extension ViewController{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            let uiImage = UIImage(data: imageData)
            UIImageWriteToSavedPhotosAlbum(uiImage!, nil,nil,nil)
            imageVIew.image = uiImage
            self.imageVIew.contentMode = UIViewContentMode.scaleAspectFit
        }
    }
}

extension ViewController{

    //画質の設定
    func setupCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    //デバイスの設定
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices{
            if device.position == AVCaptureDevice.Position.back{
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front{
                innerCamera = device
            }
        }
        currentDevice = mainCamera
    }
    
    func setupInputOutput(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    func setupPreviewLayer(){
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    func styleCaptureButton(){
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 5
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height)/2
    }
}
