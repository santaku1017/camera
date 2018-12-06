//
//  memo.swift
//  test2
//
//  Created by Intern on 2018/12/06.
//  Copyright © 2018年 Intern. All rights reserved.
//

import UIKit

class memo: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ImageView: UIImageView!
    
    var rownum:Int = 0
    var celebName:String = ""
    var celebFace:Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(data: celebFace)
        
        nameLabel.text = celebName
        ImageView.contentMode = UIViewContentMode.scaleAspectFit
        ImageView.image = image
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func retrurn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
