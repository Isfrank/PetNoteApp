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


class UserViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var supportOutlet: UIButton!
    @IBOutlet weak var askForRatingOutlet: UIButton!
    
//    let signinmaager = GSigninManager()
//    @IBAction func googleSignIn(_ sender: UIButton) {
//        signinmanager.prepareSigninAndDidApper(clientID: clientID, viewController: self) { (success, authorizer) in
//            if success{
//                self.manager.setAuthorizer(authorizer: authorizer!)
//            }
//        }
//
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.supportOutlet.layer.cornerRadius = 10
        self.askForRatingOutlet.layer.cornerRadius = 10
        
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
            let alert = UIAlertController(title: "", message: "We want to hear from you, Please send us your feedback by email in English", preferredStyle: .alert)
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
        let askController = UIAlertController(title: "Hello App User",
                                              message: "If you like this app,please rate in App Store. Thanks.",
                                              preferredStyle: .alert)
        let laterAction = UIAlertAction(title: "稍候再評",
                                        style: .default, handler: nil)
        askController.addAction(laterAction)
        let okAction = UIAlertAction(title: "我要評分", style: .default)
        { (action) -> Void in
            let appID = "12345"
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
            let username = credentials.fullName
            let useremail = credentials.email
            let realUserStatus = credentials.realUserStatus
            performSegue(withIdentifier: "segue", sender: user)
            
        default: break
        }
    }
    
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
}

//告知 ASAuthorizationController 該呈現在哪個 Window 上
extension UserViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
