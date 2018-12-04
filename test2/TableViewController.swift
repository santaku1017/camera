//
//  TableViewController.swift
//  test2
//
//  Created by Intern on 2018/11/27.
//  Copyright © 2018年 Intern. All rights reserved.
//

import UIKit
import SafariServices


class TableViewController: UITableViewController,SFSafariViewControllerDelegate {
    
    var rows:Int = 0
    var celebName: [String] = []
    var celebLink: [String] = []
    var celebImage: [Data] = []
    var resetsignal:Bool = false
    var deleterows:Bool = false
    //var celebinfo: [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = UINavigationBar()
        navBar.frame = CGRect(x: 0, y: 0, width: 320, height: 60)
        let navItem: UINavigationItem = UINavigationItem(title: "履歴")
        navItem.leftBarButtonItem = UIBarButtonItem(title: "戻る", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back))
        navItem.rightBarButtonItem = UIBarButtonItem(title: "削除", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.reset))
        navBar.pushItem(navItem, animated: true)
        self.view.addSubview(navBar)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func back(){
        if deleterows == false {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            deleterows = false
            self.performSegue(withIdentifier: "return", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewController
        vc.infoCelebName = celebName
        vc.infoLink = celebLink
        vc.infoImage = celebImage
        vc.deletecount = true
    }
    
    @objc func reset(){
//        resetsignal = true
////        let delete = ViewController()
////        delete.infoCelebName.removeAll()
////        delete.infoLink.removeAll()
        self.celebName.removeAll()
        self.celebLink.removeAll()
        self.celebImage.removeAll()
        self.rows = 1
        self.celebName += [""]
        self.celebLink += [""]
        let image = UIImage(named: "white")
        let data = UIImagePNGRepresentation(image!)
        self.celebImage.append(data!)
        deleterows = true
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = celebName[indexPath.row]
        let img = UIImage(data: celebImage[indexPath.row])
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = img
         //Configure the cell...
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let celebURL = URL(string: celebLink[indexPath.row])
        let safariController = SFSafariViewController(url: celebURL!)
        safariController.delegate = self
        self.present(safariController, animated:true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            self.celebName.remove(at: indexPath.row)
            self.celebLink.remove(at: indexPath.row)
            self.celebImage.remove(at: indexPath.row)
            self.rows = self.rows - 1
            tableView.deleteRows(at: [indexPath], with: .fade)
            deleterows  = true
        }
        else{
            print("err")
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteAction = UIContextualAction(style: .normal, title: "favorite", handler: {(action: UIContextualAction, view: UIView, completion: (Bool) -> Void) in print("favorite"); completion(true)})
        favoriteAction.backgroundColor = UIColor(red: 210/255.0, green: 82/255.0, blue: 127/255.0, alpha: 1)
        //favoriteAction.image = UIImage(named: "ic_favorite")
        
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
    
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
