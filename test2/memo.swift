//
//  memo.swift
//  test2
//
//  Created by Intern on 2018/12/06.
//  Copyright © 2018年 Intern. All rights reserved.
//

import UIKit

class memo: UIViewController,UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ImageView: UIImageView!
    
    var rownum:Int = 0
    var celebName:String = ""
    var celebFace:Data!
    
    let orderLabel = UILabel()
    let textField = UITextField()
    let RegistButton = UIButton()
    let textView = UITextView()
    
    var text:String = ""
    var dic:[String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ud = UserDefaults.standard
        let data = ud.object(forKey: "DATA")
        if data != nil {
            let Dic = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
            dic = Dic as! [String : String]
            print(dic)
        }
        
        let navBar = UINavigationBar()
        navBar.frame = CGRect(x: 0, y: 15, width: 320, height: 60)
        let navItem: UINavigationItem = UINavigationItem(title: "メモ")
        navItem.leftBarButtonItem = UIBarButtonItem(title: "戻る", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back))
        navItem.rightBarButtonItem = UIBarButtonItem(title: "削除", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.deletetext))
        navBar.pushItem(navItem, animated: true)
        self.view.addSubview(navBar)
        let image = UIImage(data: celebFace)
        
        nameLabel.text = celebName
        ImageView.contentMode = UIViewContentMode.scaleAspectFit
        ImageView.image = image
        
//        self.orderLabel.frame = CGRect(x: 25, y: 180, width: 270, height: 30)
//        self.orderLabel.text = "add memo"
//        self.view.addSubview(orderLabel)
        
        self.textField.frame = CGRect(x: 25, y: 210, width: 200, height: 40)
        self.textField.delegate = self
        self.textField.borderStyle = .roundedRect
        self.textField.clearButtonMode = .whileEditing
        self.textField.returnKeyType = .done
        self.textField.placeholder = "Enter Memo"
        self.view.addSubview(self.textField)
        
        self.RegistButton.frame = CGRect(x: 225, y: 210, width: 70, height: 40)
        self.RegistButton.backgroundColor = UIColor.blue
        self.RegistButton.layer.cornerRadius = 5.0
        self.RegistButton.setTitle("Regist", for: UIControlState.normal)
        self.RegistButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.RegistButton.addTarget(self, action: #selector(self.RegistTapped), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.RegistButton)
        
        self.textView.frame = CGRect(x: 25, y: 260, width: 270, height: 240)
        self.textView.textColor = UIColor.black
        self.textView.font = UIFont.systemFont(ofSize: 15.0)
        self.textView.returnKeyType = .done
        self.textView.isEditable = false
        if dic[celebName] != nil{
            let text = dic[celebName]
            //print(text)
            textView.text = text
        }
        else{
            textView.text = nil
        }
        self.textView.backgroundColor = UIColor.white
        self.view.addSubview(textView)
        // Do any additional setup after loading the view.
    }
    
    @objc func RegistTapped(){
        if textField.text != nil{
            text = text + textField.text! + "\n"
            self.textView.text = text
            self.textField.text = nil
            dic.updateValue(textView.text!, forKey: celebName)
        }
    }
    
    @objc func back(){
        self.Savedata()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func deletetext(){
        self.textView.text = nil
        self.dic.removeValue(forKey: celebName)
        self.Savedata()
    }
    
    func Savedata(){
        let data = NSKeyedArchiver.archivedData(withRootObject: dic)
        let ud = UserDefaults.standard
        ud.set(data, forKey: "DATA")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
