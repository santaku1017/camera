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
    @IBOutlet var label: UILabel!
    
    var infoLinksMap: [Int:String] = [100:""]
    var infoCelebName: [String] = [""]
    var infoLink: [String] = [""]
    var infoImage: [Data] = []
    //var HoldImage:UIImage!
    var celebImage:Data!
    var deletecount:Bool = false
    var Cam:Bool = false
    var imageForm:[CGFloat]!
    var Aspect:Bool = false
    let SearchButtonImage = UIImage(named: "ecalbt008_002")
    
    //var imageForm:[CGFloat] = [] //[width,height,x,y]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.setImage(SearchButtonImage, for: .normal)
        cameraButton.imageView?.contentMode = .scaleAspectFit
        cameraButton.layer.cornerRadius = 15.0
        cameraButton.isHidden = true
        
        let image = UIImage(named: "white")
        let data = UIImagePNGRepresentation(image!)
        self.infoImage.append(data!)
        
        if deletecount == true {
            self.SaveData()  //履歴画面で削除が行われていた場合
        }
        else {
            let celebdata = UserDefaults.standard
            let checkdata = celebdata.object(forKey: "NAME_LIST")
            if checkdata as? [String] != nil {
                infoCelebName = celebdata.object(forKey: "NAME_LIST") as! [String]
                infoLink = celebdata.object(forKey: "LINK_LIST") as! [String]
                infoImage = celebdata.object(forKey: "IMG_LIST") as! [Data]
            }
        }
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
        //let Requestlabels = AWSRekognitionDetectLabelsRequest()
        //let image = HoldImage
        
        let sourceImage = AWSRekognitionImage()
        sourceImage!.bytes = celebImage
        Request?.image = sourceImage
        //Requestlabels?.image = sourceImage
        
//        rekognitionClient.detectLabels(Requestlabels!) { res,err in
//            if err != nil {
//                print("err")
//            }
//            if res != nil {
//                print(res?.labels as Any)
//
//
//            }
//            else {
//                print("err")
//            }
//        }
        
        rekognitionClient.recognizeCelebrities(Request!) { res, err in
            if err != nil {
                self.NoFaces(code: "1")
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
                                
                                celebImage.name = celebFace.name!.replacingOccurrences(of: "U014d", with: "ou")
                                celebImage.Aspect = (self?.Aspect)!
                                celebImage.imageSize = self?.imageForm

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
                                let width = celebFace.face?.boundingBox?.width as! CGFloat
                                let height = celebFace.face?.boundingBox?.height as! CGFloat
                                let size = CGSize(width: (self?.imageVIew.image?.size.width)! * width, height: (self?.imageVIew.image?.size.height)! * height)
                                let x = celebFace.face?.boundingBox?.left as! CGFloat
                                let y = celebFace.face?.boundingBox?.top as! CGFloat
                                let origin = CGPoint(x: (self?.imageVIew.image?.size.width)! * x, y: (self?.imageVIew.image?.size.height)! * y)
                                let rect = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
                                let trimedImage = self?.trimmingImage((self?.imageVIew.image)!, trimmingArea: rect)
                                let trimedData = UIImagePNGRepresentation(trimedImage!)
//                                self?.imageVIew.layer.bounds.height
//                                self?.imageVIew.layer.bounds.width

                                //set celeb info
                                let Link:String = (self?.infoLinksMap[index])!
                                let nameList = self?.infoCelebName
                                self?.infoCelebName += [celebImage.name]
                                self?.infoLink += [Link]
                                let orderSetName = NSOrderedSet(array: (self?.infoCelebName)!)
                                let orderSetLink = NSOrderedSet(array: (self?.infoLink)!)
                                self?.infoCelebName = orderSetName.array as! [String]
                                self?.infoLink = orderSetLink.array as! [String]
                                if nameList != self?.infoCelebName {
                                    self?.infoImage.append(trimedData!)
                                }
                                let orderSetImage = NSOrderedSet(array: (self?.infoImage)!)
                                self?.infoImage = orderSetImage.array as! [Data]
                                //self?.celebinfo.updateValue(Link, forKey: celebImage.name)
                                
                                self?.SaveData()
                            }

                        }
                    }
                }
                else {
                    self.NoFaces(code: "2")
                }
            }
            else{
                self.NoFaces(code: "3")
            }
        }
        //self.label.text = labeltext
    }
    
    func NoFaces(code: String){
        DispatchQueue.main.async {
            self.label.text = "No celeb faces in this pic. code:" + code
        }
    }
    
    func SaveData(){
        let celebdata = UserDefaults.standard
        celebdata.set(self.infoCelebName, forKey: "NAME_LIST")
        celebdata.set(self.infoLink, forKey: "LINK_LIST")
        celebdata.set(self.infoImage, forKey: "IMG_LIST")
    }
    
    func trimmingImage(_ image: UIImage, trimmingArea: CGRect) -> UIImage {
        let imgRef = image.cgImage?.cropping(to: trimmingArea)
        let trimImage = UIImage(cgImage: imgRef!, scale: image.scale, orientation: image.imageOrientation)
        return trimImage
    }
    
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
        pickerController.sourceType = .photoLibrary
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
        getsizeofImage(image: image)
        
        if Cam == true {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            Cam = false
        }
        self.imageVIew.contentMode = UIViewContentMode.scaleAspectFit
        self.imageVIew.image = image
        self.celebImage = UIImagePNGRepresentation(image)!
        self.cameraButton.isHidden = false
        
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
        vc.celebImage = self.infoImage
        //vc.celebinfo = self.celebinfo
    }
    
    func getsizeofImage(image :UIImage){
        let width = image.size.width
        let height = image.size.height
        if 432/300 > height/width {
            Aspect = true
        }
        else {
            Aspect = false
        }
        imageForm = [width,height]
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
