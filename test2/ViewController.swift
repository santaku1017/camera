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


class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SFSafariViewControllerDelegate,UITextFieldDelegate{

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
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    var textField: UITextField!
    var RegistButton: UIButton!
    
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
    
    
    //var imageForm:[CGFloat] = [] //[width,height,x,y]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.view.subviews.count)
        cameraButton.isHidden = true
        indicator.hidesWhenStopped = true
        
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
        
        indicator.startAnimating()
        self.cameraButton.isHidden = true
        
        let rekognitionClient:AWSRekognition = AWSRekognition.default()
        let Request = AWSRekognitionRecognizeCelebritiesRequest()
        //let Requestlabels = AWSRekognitionDetectLabelsRequest()
        
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
//                let x = res.unsafelyUn
//
//            }
//            else {
//                print("err")
//            }
//        }
        
        rekognitionClient.recognizeCelebrities(Request!) { res, err in
            if err != nil {
                self.NoFaces(code: "1") // Detect error
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
                                self?.setcelebinfo(name: celebImage.name, link: (self?.infoLinksMap[index])!, image: trimedData!)


                                self?.SaveData()
                                self?.indicator.stopAnimating()
                            }

                        }
                    }
                }
                else {
                    self.NoFaces(code: "2") //responsed but no celeb face.
                }
            }
            else{
                self.NoFaces(code: "3") //No response.
            }
        }
        //self.label.text = labeltext
    }
    func setcelebinfo(name:String, link:String, image:Data){
        let Link:String = link
        let nameList = self.infoCelebName
        self.infoCelebName += [name]
        self.infoLink += [Link]
        let orderSetName = NSOrderedSet(array: (self.infoCelebName))
        let orderSetLink = NSOrderedSet(array: (self.infoLink))
        self.infoCelebName = orderSetName.array as! [String]
        self.infoLink = orderSetLink.array as! [String]
        if nameList != self.infoCelebName {
            self.infoImage.append(image)
        }
        let orderSetImage = NSOrderedSet(array: (self.infoImage))
        self.infoImage = orderSetImage.array as! [Data]
        //self?.celebinfo.updateValue(Link, forKey: celebImage.name)
    }
    
    func NoFaces(code: String){
        DispatchQueue.main.async {
            self.cameraButton.isHidden = true
            self.label.backgroundColor = UIColor.white
            self.label.text = "No celeb faces in this pic. code:" + code
            self.indicator.stopAnimating()
            
            self.textField = UITextField()
            self.RegistButton = UIButton()
            
            self.textField.frame = CGRect(x: 25, y: 70, width: 200, height: 40)
            self.textField.delegate = self
            self.textField.borderStyle = .roundedRect
            self.textField.clearButtonMode = .whileEditing
            self.textField.returnKeyType = .done
            self.textField.placeholder = "Enter Name"
            self.view.addSubview(self.textField)
            
            self.RegistButton.frame = CGRect(x: 225, y: 70, width: 70, height: 40)
            self.RegistButton.layer.cornerRadius = 5.0
            self.RegistButton.backgroundColor = UIColor.red
            self.RegistButton.setTitle("Regist", for: UIControlState.normal)
            self.RegistButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            self.RegistButton.addTarget(self, action: #selector(self.RegistTapped), for: UIControlEvents.touchUpInside)
            self.view.addSubview(self.RegistButton)
            
        }
    }
    
    @objc func RegistTapped(){
        if textField.text != nil{
            let name: String = textField.text!
            let link: String = "https://www.google.com/search?q=" + name
            let image: Data = UIImagePNGRepresentation(imageVIew.image!)!
            setcelebinfo(name: name, link: link, image: image)
            self.textField.removeFromSuperview()
            self.RegistButton.removeFromSuperview()
            self.label.text = "Complete Registration"
            self.SaveData()
        }
        else {
            self.label.text = "Please enter name!!!"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
            if (self?.view.subviews.count)! > 7{
                self?.textField.removeFromSuperview()
                self?.RegistButton.removeFromSuperview()
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
        self.imageVIew.backgroundColor = nil
        self.celebImage = UIImagePNGRepresentation(image)!
        self.cameraButton.isHidden = false
        
        self.label.backgroundColor = nil
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
        if 4/3 > height/width {
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
