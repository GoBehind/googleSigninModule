//
//  GSigninManager.swift
//  MyGDrive
//
//  Created by 王冠之 on 2020/5/18.
//  Copyright © 2020 Wangkuanchih. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
protocol GSigninManagerDelegate:AnyObject {
    func updateList(authorizer: GIDGoogleUser)
}

typealias checkSigninResult = (Bool, GTMFetcherAuthorizationProtocol?) -> Void

class GSigninManager: NSObject, GIDSignInDelegate{
    var delegate: GSigninManagerDelegate?
    let signIn = GIDSignIn.sharedInstance()
    
    func prepareSigninAndDidApper(clientID: String, viewController: UIViewController, completion: @escaping checkSigninResult){
        //prepare Google SignIn
        let signIn = GIDSignIn.sharedInstance() //Singleton, 單例模式
        signIn?.delegate = self
        signIn?.scopes = [kGTLRAuthScopeDriveFile] //存取範圍權限
        signIn?.clientID = clientID
        if ((signIn?.hasPreviousSignIn()) == true) {signIn?.restorePreviousSignIn()}
        
        guard let authorizer = signIn?.currentUser?.authentication?.fetcherAuthorizer(), let canAuthorize = authorizer.canAuthorize, canAuthorize else {
            //Need to login
            signIn?.presentingViewController = viewController
            signIn?.signIn()
            completion (false, nil)
            return
        }
        completion (true, authorizer)
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            print("Auth Fail: \(error)")
            return
        }
        let userID = user.userID ?? "n/a"
        let name = user.profile.name ?? "n/a"
        print("Auth OK: \(userID), \(name)")
        delegate?.updateList(authorizer: user)
        
    }
}
