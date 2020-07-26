//
//  UserViewController.swift
//  NoteApp
//
//  Created by frank on 2020/7/1.
//  Copyright © 2020 Frank. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI
import AuthenticationServices
import GoogleSignIn
import CoreData


class UserViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
  
    
    @IBOutlet weak var supportOutlet: UIButton!
    @IBOutlet weak var askForRatingOutlet: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var walkLabel: UILabel!
    var petName : String?
    var pet = [Pet]()
    var user: User!
    @IBOutlet weak var signOut: UIButton!
    
    
//    @IBOutlet weak var signOut: UIButton!
    //    let signinmaager = GSigninManager()
//    @IBAction func googleSignIn(_ sender: UIButton) {
//        signinmanager.prepareSigninAndDidApper(clientID: clientID, viewController: self) { (success, authorizer) in
//            if success{
//                self.manager.setAuthorizer(authorizer: authorizer!)
//            }
//        }
//
//    }
//    func didFinishupdate(pet: Pet) {
//        self.petName = pet.petName
////        self.pet = pet
//      }
    @IBAction func signOut(_ sender: UIButton) {
        checkCredentialState(withUserID: self.user.id)
        UserDefaults.standard.removeObject(forKey: "userObject")
        self.userNameLabel.text = ""
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.supportOutlet.layer.cornerRadius = 10
        self.askForRatingOutlet.layer.cornerRadius = 10
        if let u =  UserDefaults.standard.object(forKey: "userObject") as? Data {
            self.user  = try? PropertyListDecoder().decode(User.self, from: u)
            checkCredentialState(withUserID: self.user.id)
            self.userNameLabel.text = "歡迎\(self.user.lastName)" + "\(self.user.firstName)!"
        }
        //query
        let request = NSFetchRequest<Pet>(entityName: "Pet")
        do{
//            CoreDataHelper().managedObjectContext()
            pet = try CoreDataHelper.shared.managedObjectContext().fetch(request)
            if pet.count > 0 {
                self.walkLabel.text = "記得帶\(pet[0].petName!)去散步喔"
            }

        }catch{
            print("error \(error)")
        }
        
        
       UserDefaults.standard.setValue(self.userNameLabel.text, forKey: "user")
        guard let name = UserDefaults.standard.value(forKey: "user")  else{
            return
        }
        self.userNameLabel.text = name as? String
       
        
        
//        signinmaager.delegate = self

        // Do any additional setup after loading the view.
    }
    func setupView() {
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.addTarget(self, action: #selector(didTapAppleButton), for: .touchUpInside)
        view.addSubview(appleButton)
        NSLayoutConstraint.activate([
            appleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            appleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            appleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    @IBAction func support(){
        
        if ( MFMailComposeViewController.canSendMail()){
//            let alert = UIAlertController(title: "", message: "We want to hear from you, Please send us your feedback by email in English", preferredStyle: .alert)
             let alert = UIAlertController(title: "", message: "如果有任何問題請不吝隨時與我聯絡，我會盡快給您答覆～", preferredStyle: .alert)
            let laterAction = UIAlertAction(title: "取消",style: .default, handler: nil)
            alert.addAction(laterAction)
            let email = UIAlertAction(title: "email", style: .default, handler: { (action) -> Void in
                let mailController =  MFMailComposeViewController()
                mailController.mailComposeDelegate = self
                mailController.title = "I have question"
                mailController.setSubject("I have question")
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                let product = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")
                let messageBody = "<br/><br/><br/>Product:\(product!)(\(version!))"
                mailController.setMessageBody(messageBody, isHTML: true)
                mailController.setToRecipients(["downtotheapp@gmail.com"])
                self.present(mailController, animated: true, completion: nil)
            })
            alert.addAction(email)
            self.present(alert, animated: true, completion: nil)
        }else{
            //alert user can't send email
        }
    }
    @IBAction func askForRating(){
        
//         SKStoreReviewController.requestReview()
//        let askController = UIAlertController(title: "Hello App User",
//                                              message: "If you like this app,please rate in App Store. Thanks.",
//                                              preferredStyle: .alert)
        let askController = UIAlertController(title: "嗨",
                                                     message: "如果喜歡這個APP，請幫我評分給個鼓勵吧～",
                                                     preferredStyle: .alert)
        let laterAction = UIAlertAction(title: "稍候再評",
                                        style: .default, handler: nil)
        askController.addAction(laterAction)
        let okAction = UIAlertAction(title: "我要評分", style: .default)
        { (action) -> Void in
            let appID = "1519972161"
            let appURL =
                URL(string: "https://itunes.apple.com/us/app/itunes-u/id\(appID)?action=write-review")!
            UIApplication.shared.open(appURL, options: [:],
                                      completionHandler: { (success) in
            })
        }
        askController.addAction(okAction)
        self.present(askController, animated: true, completion: nil)
    }
    //apple Sign in
     @objc
        func didTapAppleButton() {
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
            //用來實作登入成功、失敗的邏輯、來告知ASAuthorizationController該呈現在哪個 Window 上
        }

//        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if let secVC = segue.destination as? secondViewController, let user = sender as? User {
//                secVC.user = user
//            }
//        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

extension UserViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        //只有第一次登入時，會取得除了 User ID 的資料。
        //所以必須得將其資料存放在 Server 端，以利後續使用。
        switch authorization.credential {
            
        case let credentials as ASAuthorizationAppleIDCredential:
            let user = User(credentials: credentials)
//            let username = credentials.fullName
//            let useremail = credentials.email
//            let realUserStatus = credentials.realUserStatus
            self.user = user
            self.userNameLabel.text = "歡迎\(user.lastName)" + "\(user.firstName)!"
            if pet.count > 0 {
            self.walkLabel.text = "記得帶\(pet[0].petName!)去散步哦"
            }
            UserDefaults.standard.set( try? PropertyListEncoder().encode(user), forKey: "userObject")
            
//            UserDefaults.standard.setValue(self.userNameLabel.text, forKey: "user")
//            guard let name = UserDefaults.standard.value(forKey: "user")  else{
//                return
//            }
//            self.userNameLabel.text = name as? String


            
//            performSegue(withIdentifier: "segue", sender: user)
            
        default: break
        }
    }
    //授權失敗
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        print("something bad happened", error)
        switch (error) {
        case ASAuthorizationError.canceled:
            break
        case ASAuthorizationError.failed:
            break
        case ASAuthorizationError.invalidResponse:
            break
        case ASAuthorizationError.notHandled:
            break
        case ASAuthorizationError.unknown:
            break
        default:
            break
        }
    }
    private func checkCredentialState(withUserID userID: String) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                // 用戶已登入
                DispatchQueue.main.async {
                    self.signOut.isEnabled = true
                }
                break
            case .revoked:
                // 用戶已登出
                UserDefaults.standard.removeObject(forKey: "userObject")
                DispatchQueue.main.async {
                 self.userNameLabel.text = ""
                }
                break
            case .notFound:
                // 無此用戶
                break;
            default:
                break
            }
        }
    }
}

//告知 ASAuthorizationController 該呈現在哪個 Window 上
extension UserViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

