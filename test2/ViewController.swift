//
//  ViewController.swift
//  test2
//
//  Created by Intern on 2018/11/13.
//  Copyright © 2018年 Intern. All rights reserved.
//

import UIKit
import AWSRekognition
import SafariServices
//import AVFoundation

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SFSafariViewControllerDelegate{

//    var captureSession = AVCaptureSession()
//    var mainCamera : AVCaptureDevice?
//    var innerCamera : AVCaptureDevice?
//    var currentDevice : AVCaptureDevice?
//    var photoOutput : AVCapturePhotoOutput?
//    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var imageVIew: UIImageView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var Search: UIButton!
    @IBOutlet var label: UILabel!
    
    var infoLinksMap: [Int:String] = [100:""]
    var infoCelebName: [String] = []
    var infoLink: [String] = []
    //var celebinfo: [String:String] = [:]
    var searchButton:UIButton!
    //var HoldImage:UIImage!
    var celebImage:Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Search.isHidden = true
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
//        let settings = AVCapturePhotoSettings()
//
//        settings.flashMode = .auto
//        settings.isAutoStillImageStabilizationEnabled = true
//
//        self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
//        imageVIew.image = nil
        
        
        let rekognitionClient:AWSRekognition = AWSRekognition.default()
        let Request = AWSRekognitionRecognizeCelebritiesRequest()
        //let image = HoldImage
        
        let sourceImage = AWSRekognitionImage()
        sourceImage!.bytes = celebImage
        Request?.image = sourceImage
        
        
        rekognitionClient.recognizeCelebrities(Request!) { res, err in
            if err != nil {
                DispatchQueue.main.async {
                    self.NoFaces(code: "1")
                    return
                }
            }
            
            if res != nil {
                print(res!.celebrityFaces!.enumerated())

                if((res!.celebrityFaces?.count)! > 0){
                    for (index, celebFace) in res!.celebrityFaces!.enumerated(){
                        if(celebFace.matchConfidence!.intValue > 50){
                            DispatchQueue.main.async{
                                [weak self] in
//                                self?.label.text = celebFace.name!
//                                self?.Search.isHidden = false
//                                self?.Search.isEnabled = true

//                                let SearchButton:UIButton = (self?.createButton())!
//                                SearchButton.tag = 1
//                                SearchButton.addTarget(self, action: #selector(self?.search), for: UIControlEvents.touchUpInside)
//                                self?.mainView.addSubview(SearchButton)
                                
                                let celebImage = Celebrity()

                                celebImage.scene = (self?.imageVIew)!

                                celebImage.boundingBox = ["height":celebFace.face?.boundingBox?.height,"left":celebFace.face?.boundingBox?.left,"top":celebFace.face?.boundingBox?.top, "width":celebFace.face?.boundingBox?.width] as! [String : CGFloat]

                                celebImage.name = celebFace.name!
                                //celebImage.matchConfidence = celebFace.matchConfidence! as! Int

//                                if (celebFace.urls!.count > 0){
//                                    celebImage.infoLink = celebFace.urls![0]
//                                } else {
//                                    celebImage.infoLink = "www.google.com/search?q=" + celebImage.name
//                                }
                                
                                //replace space with +
                                let text:String = celebImage.name
                                let Text = text.replacingOccurrences(of: " ", with: "+")
                                self?.infoLinksMap[index] = "https://www.google.com/search?q=" + Text
                                
                                //create info button
                                let infoButton:UIButton = celebImage.createInfoButton()
                                infoButton.tag = index
                                infoButton.addTarget(self, action: #selector(self?.handleTap), for: UIControlEvents.touchUpInside)
                                self?.imageVIew.addSubview(infoButton)
                                
                                //create layer
                                let Layer:CAShapeLayer = celebImage.createLayer()
                                self?.imageVIew.layer.addSublayer(Layer)
                                
                                //set celeb info
                                let Link:String = (self?.infoLinksMap[index])!
                                self?.infoCelebName += [celebImage.name]
                                self?.infoLink += [Link]
                                //self?.celebinfo.updateValue(Link, forKey: celebImage.name)
                            }
                            
                        }
                    }
                }
                else {
                    self.NoFaces(code: "2")
                }
            }
            else{
                DispatchQueue.main.async {
                    self.NoFaces(code: "3")
                }
            }
        }
        //self.label.text = labeltext
    }
    
    func NoFaces(code: String){
        DispatchQueue.main.async {
            self.label.text = "No celeb faces in this pic. code:" + code
        }
    }
    
    var Cam:Bool = false
    @IBAction func startCamera(_ sender: Any) {
        Cam = true
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        pickerController.cameraCaptureMode = .photo
        present(pickerController, animated: true, completion: nil)
    }
    @IBAction func startAlbum(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true, completion: nil)
    }
    
//    @objc func search(){
//        let text:String = self.label.text!
//        let Text = text.replacingOccurrences(of: " ", with: "+")
//        let vc = SFSafariViewController(url: URL(string: "https://www.google.com/search?q=" + Text)!)
//        present(vc, animated: true, completion: nil)
//    }
    
//    @IBAction func SearchToupped(_ sender: Any) {
//        let text:String = self.label.text!
//        let Text = text.replacingOccurrences(of: " ", with: "+")
//        let vc = SFSafariViewController(url: URL(string: "https://www.google.com/search?q=" + Text)!)
//        present(vc, animated: true, completion: nil)
//    }
    
    //selected Photo from Album or Toupped "Use" in Camera View
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //delete info button
        DispatchQueue.main.async {
            [weak self] in
            for subView in (self?.imageVIew.subviews)! {
                subView.removeFromSuperview()
                self?.imageVIew.layer.sublayers = nil
            }
        }
        
        dismiss(animated: true)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("couldn't load image from Photos")
        }
        if Cam == true {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            Cam = false
        }
        self.imageVIew.contentMode = UIViewContentMode.scaleAspectFit
        self.imageVIew.image = image
        self.celebImage = UIImagePNGRepresentation(image)!
        
        self.label.text = nil
    }
    
    // info button toupped
    @objc func handleTap(sender:UIButton){
        print("tap recognized")
        let celebURL = URL(string: self.infoLinksMap[sender.tag]!)
        let safariController = SFSafariViewController(url: celebURL!)
        safariController.delegate = self
        self.present(safariController, animated:true)
    }
    
    @IBAction func Table(_ sender: Any) {
        self.performSegue(withIdentifier: "toTable", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! TableViewController
        vc.rows = self.infoCelebName.count
        vc.celebName = self.infoCelebName
        vc.celebLink = self.infoLink
        //vc.celebinfo = self.celebinfo
    }
    
//    func createButton()-> UIButton{
//
//        self.searchButton = UIButton.init(frame: CGRect(origin: CGPoint(x: 233,y: 460), size: CGSize(width: 65, height: 15)))
//        self.searchButton.backgroundColor = UIColor.white
//        self.searchButton.clipsToBounds = true
//        self.searchButton.layer.cornerRadius = 8
//        self.searchButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
//        self.searchButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        self.searchButton.titleLabel?.textAlignment = NSTextAlignment.center
//        self.searchButton.setTitle("Search", for: UIControlState.normal)
//
//        return self.searchButton
//    }
    
}

//extension ViewController{
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        if let imageData = photo.fileDataRepresentation(){
//            let uiImage = UIImage(data: imageData)
//            UIImageWriteToSavedPhotosAlbum(uiImage!, nil,nil,nil)
//            imageVIew.image = uiImage
//            self.imageVIew.contentMode = UIViewContentMode.scaleAspectFit
//        }
//    }
//}
//
//extension ViewController{
//
//    //画質の設定
//    func setupCaptureSession(){
//        captureSession.sessionPreset = AVCaptureSession.Preset.photo
//    }
//
//    //デバイスの設定
//    func setupDevice(){
//        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
//        let devices = deviceDiscoverySession.devices
//
//        for device in devices{
//            if device.position == AVCaptureDevice.Position.back{
//                mainCamera = device
//            } else if device.position == AVCaptureDevice.Position.front{
//                innerCamera = device
//            }
//        }
//        currentDevice = mainCamera
//    }
//
//    func setupInputOutput(){
//        do {
//            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
//            captureSession.addInput(captureDeviceInput)
//            photoOutput = AVCapturePhotoOutput()
//            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
//            captureSession.addOutput(photoOutput!)
//        } catch {
//            print(error)
//        }
//    }
//
//    func setupPreviewLayer(){
//        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//
//        self.cameraPreviewLayer?.frame = view.frame
//        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
//    }
//
//    func styleCaptureButton(){
//        cameraButton.layer.borderColor = UIColor.white.cgColor
//        cameraButton.layer.borderWidth = 5
//        cameraButton.clipsToBounds = true
//        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height)/2
//    }
//}
