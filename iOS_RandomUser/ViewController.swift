//
//  ViewController.swift
//  iOS_RandomUser
//
//  Created by 王麒翔 on 2023/8/2.
//

import UIKit

struct User {
    var name:String?
    var email:String?
    var number:String?
    var image:String?
}

class ViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    func settingInfo(user: User) {
        userName.text = user.name
        infoTableViewController?.phoneLabel.text = user.number
        infoTableViewController?.emailLabel.text = user.email
//        user.image
    }
    
    var infoTableViewController:InfoTableViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moreInfo" {
            infoTableViewController = segue.destination as? InfoTableViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // mock data
        let aUser = User(name: "Alice", email: "alice@test.com", number: "777-7777", image: "http://picture.me");
        settingInfo(user: aUser)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 畫面已載入記憶體 才設定畫面
        
        // make user image circle // CALayer
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
    }


}

