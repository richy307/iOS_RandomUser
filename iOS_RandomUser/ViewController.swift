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

// 1. 字典需要加人新的結構模仿，其他不用
// 2. 需要的資料才需要模仿，不需要的資料不用管
// 3. 模仿資料的屬性要跟 Key 的名稱一樣
struct AllData:Decodable {
    var results: [SingleData]?
}

struct SingleData:Decodable {
    var name: Name?
    var email: String?
    var phone: String?
    var picture: Picture?
}

struct Name:Decodable {
    var first: String?
    var last: String?
}

struct Picture:Decodable {
    var large: String?
}


class ViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    func settingInfo(user: User) {
        userName.text = user.name
        infoTableViewController?.phoneLabel.text = user.number
        infoTableViewController?.emailLabel.text = user.email
        
        if let imageAddress = user.image {
            if let imageURL = URL(string: imageAddress) {
                let task = urlSession.downloadTask(with: imageURL) {
                    
                    (url, urlResponse, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.popAlert(withTitle: "sorry")
                        }
                        return
                    }
                    
                    if let okURL = url {
                        do {
                            let downloadImage = UIImage(data: try Data(contentsOf: okURL))
                            DispatchQueue.main.async {
                                self.userImage.image = downloadImage
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.popAlert(withTitle: "sorry")
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func downloadInfo(withAddress webAddress:String) {
        if let url = URL(string: webAddress) {
            // Api Task
            let task = urlSession.dataTask(with: url) {
                (data, urlResponse, error) in
                if error != nil {
                    let errorCode = (error! as NSError).code
                    if errorCode == -1009 {
                        // print("no internet connection")
                        DispatchQueue.main.async {
                            self.popAlert(withTitle: "no internet connection")
                        }
                    } else {
                        // print("something's wrong")
                        DispatchQueue.main.async {
                            self.popAlert(withTitle: "sorry")
                        }
                    }
                    return
                }
                
                if let loadedData = data {
                    // print("got data")
                    do {
                        // 舊方法
//                        let json = try JSONSerialization.jsonObject(with: loadedData, options: [])
//                        DispatchQueue.main.async {
//                            self.parseJson(json: json)
//                        }
                        
                        // 新方法
                        let okData = try JSONDecoder().decode(AllData.self, from: loadedData)
                        
                        let firstname = okData.results?[0].name?.first
                        let lastname = okData.results?[0].name?.last
                        let fullname:String? = {
                            guard let okFirstname = firstname, let okLasttname = lastname else { return nil }
                            return okFirstname + " " + okLasttname
                        }()
                        let email = okData.results?[0].email
                        let phone = okData.results?[0].phone
                        let picture = okData.results?[0].picture?.large
                        
                        let aUser = User(name: fullname, email: email, number: phone, image: picture)
                        DispatchQueue.main.async {
                            self.settingInfo(user: aUser)
                        }
                        
                    } catch {
                        DispatchQueue.main.async {
                            self.popAlert(withTitle: "sorry")
                        }
                    }
                }
            }
            // call Api
            task.resume()
        }
    }
    
    func userFullName(nameDictionary: Any?) -> String? {
        if let okDictionary = nameDictionary as? [String:String] {
            let firstname = okDictionary["first"] ?? ""
            let lastname = okDictionary["last"] ?? ""
            return firstname + " " + lastname
        } else {
            return nil
        }
    }
    
    func parseJson(json: Any) {
        if let okJson = json as? [String:Any] {
            if let infoArray = okJson["results"] as? [[String:Any]] {
                
                let infoDictionary = infoArray[0]
                // print(infoDictionary["name"])
                let loadedName = userFullName(nameDictionary: infoDictionary["name"])
                let loadedEmail = infoDictionary["email"] as? String
                let loadedPhone = infoDictionary["phone"] as? String
                let imageDictionary = infoDictionary["picture"] as? [String:String]
                let loadedImageAddress = imageDictionary?["large"]
                let loadedUser = User(name: loadedName, email: loadedEmail, number: loadedPhone, image: loadedImageAddress)
                
                settingInfo(user: loadedUser)
            }
        }
    }
    
    func popAlert(withTitle title:String) {
        let alert = UIAlertController(title: title, message: "Please try again later", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    var infoTableViewController:InfoTableViewController?
    let apiAddress = "https://randomuser.me/api/"
    var urlSession = URLSession(configuration: .default)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moreInfo" {
            infoTableViewController = segue.destination as? InfoTableViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // mock data
        // let aUser = User(name: "Alice", email: "alice@test.com", number: "777-7777", image: "http://picture.me");
        // settingInfo(user: aUser)
        
        // Real Api Data
        downloadInfo(withAddress: apiAddress)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 畫面已載入記憶體 才設定畫面
        
        // make user image circle // CALayer
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
    }

}

